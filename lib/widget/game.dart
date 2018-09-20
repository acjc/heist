import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/keys.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/request_reducers.dart';
import 'package:heist/reducers/subscription_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/bidding.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/decision.dart';
import 'package:heist/widget/endgame.dart';
import 'package:heist/widget/game_history.dart';
import 'package:heist/widget/gifting.dart';
import 'package:heist/widget/haunt_end.dart';
import 'package:heist/widget/round_end.dart';
import 'package:heist/widget/secret_board.dart';
import 'package:heist/widget/selection_board.dart';
import 'package:heist/widget/team_selection.dart';
import 'package:redux/redux.dart';

class Game extends StatefulWidget {
  final Store<GameModel> _store;

  Game(this._store);

  @override
  State<StatefulWidget> createState() {
    return new GameState(_store);
  }
}

class GameState extends State<Game> {
  final Store<GameModel> _store;
  StreamSubscription _connectivitySubscription;
  Timer _connectivityTimer;

  GameState(this._store);

  @override
  void initState() {
    super.initState();
    _store.dispatch(new LoadGameAction());
    _connectivitySubscription =
        new Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Note that on Android, this does not guarantee connection to Internet.
      // For instance, the app might have wifi access but it might be a VPN or
      // a hotel WiFi with no access.
      debugPrint('Status changed: ' + result.toString());
      if (result == ConnectivityResult.none) {
        // connectivity was lost, start the timer
        _connectivityTimer =
            new Timer(const Duration(seconds: 5), () => showNoConnectionDialog(context));
      } else {
        // connectivity is back, cancel the timer
        _connectivityTimer?.cancel();
        // and dismiss the dialog if it's shown
        if (Keys.noConnectionDialogKey.currentWidget != null) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    resetGameStore(_store);
    super.dispose();
  }

  Widget _resolveEndgame(bool completingGame) {
    if (!getRoom(_store.state).complete && !completingGame) {
      _store.dispatch(new CompleteGameAction());
    }
    return endgame(context, _store);
  }

  Widget _resolveAuctionWinners(bool resolvingAuction) {
    if (amOwner(_store.state) && !resolvingAuction) {
      _store.dispatch(new ResolveAuctionWinnersAction());
    }
    return null;
  }

  Widget _biddingAndGifting(Store<GameModel> store) {
    List<Widget> children = [
      roundTitleCard(context, store),
    ];
    if (!isAuction(store.state)) {
      children.add(selectionBoard(_store));
    }
    children.add(
      bidding(store),
    );
    children.add(gifting(store));
    return ListView(children: children);
  }

  Widget _gameLoop(MainBoardViewModel viewModel) {
    // Allow local continues from bidding summary
    if (viewModel.waitingForTeam && !viewModel.previousRoundContinued) {
      return appendGameHistory(RoundEnd(_store, viewModel.currentRoundOrder - 1));
    }

    // Current haunt has happened so ask to complete it
    if (viewModel.hauntDecided && !viewModel.hauntComplete) {
      return appendGameHistory(HauntEnd(_store));
    }

    // Haunt is currently happening
    if (viewModel.hauntIsActive) {
      return appendGameHistory(activeHaunt(context, _store));
    }

    // Team selection (not needed for auctions)
    if (!isAuction(_store.state) &&
        (viewModel.waitingForTeam || !viewModel.teamSelectionContinued)) {
      return TeamSelection(_store, isMyGo(_store.state));
    }

    // Bidding & gifting
    if (!viewModel.biddingComplete) {
      return appendGameHistory(_biddingAndGifting(_store));
    }

    // Select team from auction if necessary
    if (isAuction(_store.state) && viewModel.waitingForTeam) {
      return _resolveAuctionWinners(viewModel.resolvingAuction);
    }

    // Bidding summary
    if (!viewModel.roundComplete) {
      return appendGameHistory(RoundEnd(_store, viewModel.currentRoundOrder));
    }

    return null;
  }

  Widget appendGameHistory(Widget child) => new Column(
        children: [
          new Expanded(child: child),
          gameHistory(_store),
        ],
      );

  Widget _mainBoardBody() => StoreConnector<GameModel, MainBoardViewModel>(
        ignoreChange: (gameModel) => currentHaunt(gameModel) == null,
        converter: (store) {
          Haunt haunt = currentHaunt(store.state);
          Round round = currentRound(store.state);
          return MainBoardViewModel._(
            currentRoundOrder: round.order,
            previousRoundContinued: round.order == 1 ||
                localRoundActionRecorded(
                  store.state,
                  previousRound(store.state).id,
                  LocalRoundAction.RoundEndContinue,
                ),
            waitingForTeam: !round.teamSubmitted,
            teamSelectionContinued: localRoundActionRecorded(
              store.state,
              round.id,
              LocalRoundAction.TeamSelectionContinue,
            ),
            biddingComplete: biddingComplete(store.state),
            resolvingAuction: requestInProcess(store.state, Request.ResolvingAuction),
            roundComplete: round.complete,
            hauntIsActive: hauntIsActive(store.state),
            hauntDecided: haunt.allDecided,
            hauntComplete: haunt.complete,
          );
        },
        distinct: true,
        builder: (context, viewModel) {
          Widget currentScreen = _gameLoop(viewModel);
          if (currentScreen == null) {
            return loading();
          }
          return currentScreen;
        },
      );

  Widget _waitingForPlayers(List<Player> playersSoFar, int numPlayers) {
    List<Widget> children = [
      Padding(
        padding: paddingTitle,
        child: Text(
          AppLocalizations.of(context).waitingForPlayers(playersSoFar.length, numPlayers),
          style: titleTextStyle,
        ),
      ),
    ];
    children.addAll(List.generate(playersSoFar.length, (i) => Text(playersSoFar[i].name)));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _loadingScreen() => StoreConnector<GameModel, LoadingScreenViewModel>(
        converter: (store) => LoadingScreenViewModel._(roomIsAvailable(store.state),
            waitingForPlayers(store.state), isNewGame(store.state), getPlayers(store.state)),
        distinct: true,
        builder: (context, viewModel) {
          if (!viewModel.roomIsAvailable) {
            return loading();
          }

          if (viewModel.waitingForPlayers) {
            return _waitingForPlayers(viewModel.playersSoFar, getRoom(_store.state).numPlayers);
          }

          if (viewModel.isNewGame) {
            return centeredMessage(AppLocalizations.of(context).initialisingGame);
          }

          return loading();
        },
      );

  Widget _mainBoard() => StoreConnector<GameModel, GameActiveViewModel>(
      converter: (store) => GameActiveViewModel._(gameIsReady(store.state), gameOver(store.state),
          requestInProcess(store.state, Request.CompletingGame)),
      distinct: true,
      builder: (context, viewModel) {
        if (!viewModel.gameIsReady) {
          return _loadingScreen();
        }
        if (viewModel.gameOver) {
          return _resolveEndgame(viewModel.completingGame);
        }
        return _mainBoardBody();
      });

  Widget _secretBoard() => StoreConnector<GameModel, bool>(
        converter: (store) => gameIsReady(store.state),
        distinct: true,
        builder: (context, gameIsReady) => gameIsReady ? SecretBoard(_store) : _loadingScreen(),
      );

  Widget _secretTab() => StoreConnector<GameModel, bool>(
        converter: (store) =>
            getHaunts(store.state).isNotEmpty ? haveReceivedGiftThisRound(store.state) : false,
        distinct: true,
        builder: (context, haveReceivedGiftThisRound) {
          Text title = Text(AppLocalizations.of(context).secretTab);
          return haveReceivedGiftThisRound ? iconText(Icon(Icons.cake), title) : title;
        },
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
              alignment: Alignment.center,
              padding: paddingNano,
              child: Text(
                getRoom(_store.state).code,
                style: boldTextStyle,
              )),
          title: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context).gameTab),
              _secretTab(),
            ],
          ),
        ),
        endDrawer: isDebugMode() ? Drawer(child: ReduxDevTools<GameModel>(_store)) : null,
        body: TabBarView(
          children: [
            _mainBoard(),
            _secretBoard(),
          ],
        ),
      ),
    );
  }
}

class LoadingScreenViewModel {
  final bool roomIsAvailable;
  final bool waitingForPlayers;
  final bool isNewGame;
  final List<Player> playersSoFar;

  LoadingScreenViewModel._(
      this.roomIsAvailable, this.waitingForPlayers, this.isNewGame, this.playersSoFar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingScreenViewModel &&
          roomIsAvailable == other.roomIsAvailable &&
          waitingForPlayers == other.waitingForPlayers &&
          isNewGame == other.isNewGame &&
          playersSoFar == other.playersSoFar;

  @override
  int get hashCode =>
      roomIsAvailable.hashCode ^
      waitingForPlayers.hashCode ^
      isNewGame.hashCode ^
      playersSoFar.hashCode;

  @override
  String toString() {
    return 'LoadingScreenViewModel{roomIsAvailable: $roomIsAvailable, waitingForPlayers: $waitingForPlayers, isNewGame: $isNewGame, playersSoFar: $playersSoFar}';
  }
}

class MainBoardViewModel {
  final int currentRoundOrder;
  final bool previousRoundContinued;
  final bool waitingForTeam;
  final bool teamSelectionContinued;
  final bool biddingComplete;
  final bool resolvingAuction;
  final bool roundComplete;

  final bool hauntIsActive;
  final bool hauntDecided;
  final bool hauntComplete;

  MainBoardViewModel._(
      {@required this.currentRoundOrder,
      @required this.previousRoundContinued,
      @required this.waitingForTeam,
      @required this.teamSelectionContinued,
      @required this.biddingComplete,
      @required this.resolvingAuction,
      @required this.roundComplete,
      @required this.hauntIsActive,
      @required this.hauntDecided,
      @required this.hauntComplete});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainBoardViewModel &&
          runtimeType == other.runtimeType &&
          currentRoundOrder == other.currentRoundOrder &&
          previousRoundContinued == other.previousRoundContinued &&
          waitingForTeam == other.waitingForTeam &&
          teamSelectionContinued == other.teamSelectionContinued &&
          biddingComplete == other.biddingComplete &&
          resolvingAuction == other.resolvingAuction &&
          roundComplete == other.roundComplete &&
          hauntIsActive == other.hauntIsActive &&
          hauntDecided == other.hauntDecided &&
          hauntComplete == other.hauntComplete;

  @override
  int get hashCode =>
      currentRoundOrder.hashCode ^
      previousRoundContinued.hashCode ^
      waitingForTeam.hashCode ^
      teamSelectionContinued.hashCode ^
      biddingComplete.hashCode ^
      resolvingAuction.hashCode ^
      roundComplete.hashCode ^
      hauntIsActive.hashCode ^
      hauntDecided.hashCode ^
      hauntComplete.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{currentRoundOrder: $currentRoundOrder, previousRoundContinued: $previousRoundContinued, waitingForTeam: $waitingForTeam, teamSelectionContinued: $teamSelectionContinued, biddingComplete: $biddingComplete, resolvingAuction: $resolvingAuction, roundComplete: $roundComplete, hauntIsActive: $hauntIsActive, hauntDecided: $hauntDecided, hauntComplete: $hauntComplete}';
  }
}

class GameActiveViewModel {
  final bool gameIsReady;
  final bool gameOver;
  final bool completingGame;

  GameActiveViewModel._(this.gameIsReady, this.gameOver, this.completingGame);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameActiveViewModel &&
          gameIsReady == other.gameIsReady &&
          gameOver == other.gameOver &&
          completingGame == other.completingGame;

  @override
  int get hashCode => gameIsReady.hashCode ^ gameOver.hashCode ^ completingGame.hashCode;

  @override
  String toString() {
    return 'GameActiveViewModel{gameIsReady: $gameIsReady, gameOver: $gameOver, completingGame: $completingGame}';
  }
}

void resetGameStore(Store<GameModel> store) {
  store.dispatch(ClearAllPendingRequestsAction());
  store.dispatch(CancelSubscriptionsAction());
  store.dispatch(UpdateStateAction<LocalActions>(LocalActions.initial()));

  store.dispatch(UpdateStateAction<Room>(Room.initial(isDebugMode() ? 2 : minPlayers)));
  store.dispatch(UpdateStateAction<List<Player>>([]));
  store.dispatch(UpdateStateAction<List<Haunt>>([]));
  store.dispatch(UpdateStateAction<Map<Haunt, List<Round>>>({}));
}
