import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:heist/widget/background.dart';
import 'package:heist/widget/bidding.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/decision.dart';
import 'package:heist/widget/endgame.dart';
import 'package:heist/widget/game_history.dart';
import 'package:heist/widget/gifting.dart';
import 'package:heist/widget/haunt_end.dart';
import 'package:heist/widget/roles_selection.dart';
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
  final PageController _controller = PageController();
  StreamSubscription _connectivitySubscription;
  Timer _connectivityTimer;

  GameState(this._store);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _store.dispatch(new LoadGameAction());
    _connectivitySubscription =
        new Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Note that on Android, this does not guarantee connection to Internet.
      // For instance, the app might have wifi access but it might be a VPN or
      // a hotel WiFi with no access.
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
      _store.dispatch(CompleteGameAction());
    }
    return Endgame(_store);
  }

  Widget _resolveAuctionWinners(bool resolvingAuction) {
    if (amOwner(_store.state) && !resolvingAuction) {
      _store.dispatch(ResolveAuctionWinnersAction());
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
    children.addAll(
      [
        bidding(store),
        gifting(store),
      ],
    );
    return Padding(
      padding: paddingSmall,
      child: ListView(children: children),
    );
  }

  Widget _gameLoop(MainBoardViewModel viewModel) {
    // If a team has not been selected for the current round
    if (!viewModel.currentRound.teamSubmitted) {
      // Show bidding summary of previous round
      if (viewModel.currentRound.order > 1 &&
          !roundContinued(viewModel.localActions, previousRound(_store.state))) {
        return Theme(data: lightTheme, child: RoundEnd(_store, viewModel.currentRound.order - 1));
      }
      // Or haunt summary of previous haunt
      if (viewModel.currentHaunt.order > 1 &&
          !hauntContinued(viewModel.localActions, previousHaunt(_store.state))) {
        return appendFooter(HauntEnd(_store, viewModel.currentHaunt.order - 1));
      }
    }

    // Team selection (not needed for auctions)
    if (!isAuction(_store.state) &&
        !viewModel.biddingComplete &&
        (!viewModel.currentRound.teamSubmitted ||
            !teamSelectionContinued(viewModel.localActions, viewModel.currentRound))) {
      return Theme(data: lightTheme, child: TeamSelection(_store, isMyGo(_store.state)));
    }

    // Bidding & gifting
    if (!viewModel.biddingComplete) {
      return appendFooter(_biddingAndGifting(_store));
    }

    // Select team from auction if necessary
    if (isAuction(_store.state) && !viewModel.currentRound.teamSubmitted) {
      return _resolveAuctionWinners(viewModel.resolvingAuction);
    }

    // Bidding summary
    if (!viewModel.currentRound.complete ||
        !roundContinued(viewModel.localActions, viewModel.currentRound)) {
      return Theme(data: lightTheme, child: RoundEnd(_store, viewModel.currentRound.order));
    }

    // Haunt is currently happening
    if (viewModel.hauntIsActive) {
      return appendFooter(ActiveHaunt(_store));
    }

    // Current haunt has happened so ask to complete it
    if (viewModel.currentHaunt.allDecided && !viewModel.currentHaunt.complete) {
      return appendFooter(HauntEnd(_store, viewModel.currentHaunt.order));
    }

    return null;
  }

  Widget appendFooter(Widget child, {bool indicatorOnRight = true}) => Column(
        children: [
          Expanded(child: child),
          footer(indicatorOnRight),
        ],
      );

  Widget footer(bool indicatorOnRight) {
    Widget gameHistory = Expanded(
      child: GameHistory(_store),
    );

    List<Widget> children =
        indicatorOnRight ? [gameHistory, rightIndicator()] : [leftIndicator(), gameHistory];
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
      child: Row(children: children),
    );
  }

  static const EdgeInsets indicatorPadding =
      const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0);

  Widget rightIndicator() => StoreConnector<GameModel, bool>(
        distinct: true,
        ignoreChange: (gameModel) => !gameIsReady(gameModel),
        converter: (store) => haveReceivedGiftThisRound(store.state),
        builder: (context, haveReceivedGiftThisRound) {
          List<Widget> children = [];
          if (haveReceivedGiftThisRound) {
            children.add(Icon(
              Icons.cake,
              color: Colors.white70,
              size: 16.0,
            ));
          }
          children.add(Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white70,
            size: 32.0,
          ));
          return Card(
            elevation: 10.0,
            color: Colors.white24,
            child: InkWell(
              onTap: () => _controller.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                  ),
              child: Padding(
                padding: indicatorPadding,
                child: Row(children: children),
              ),
            ),
          );
        },
      );

  Widget leftIndicator() => Card(
        elevation: 10.0,
        color: Colors.white24,
        child: InkWell(
          child: Padding(
            padding: indicatorPadding,
            child: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white70,
              size: 32.0,
            ),
          ),
          onTap: () => _controller.previousPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              ),
        ),
      );

  Widget _mainBoardBody() => StoreConnector<GameModel, MainBoardViewModel>(
        ignoreChange: (gameModel) => currentHaunt(gameModel) == null,
        converter: (store) {
          Haunt haunt = currentHaunt(store.state);
          Round round = currentRound(store.state);
          return MainBoardViewModel._(
            currentHaunt: haunt,
            currentRound: round,
            localActions: getLocalActions(_store.state),
            biddingComplete: biddingComplete(store.state),
            resolvingAuction: requestInProcess(store.state, Request.ResolvingAuction),
            hauntIsActive: currentHauntIsActive(store.state),
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
          style: Theme.of(context).textTheme.title,
        ),
      ),
    ]..addAll(List.generate(playersSoFar.length, (i) => Text(playersSoFar[i].name)));
    return Center(
      child: Card(
        elevation: 2.0,
        margin: paddingLarge,
        child: Padding(
          padding: paddingLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _loadingScreen() => StoreConnector<GameModel, LoadingScreenViewModel>(
        converter: (store) => LoadingScreenViewModel._(
            roomIsAvailable(store.state),
            rolesSubmitted(store.state),
            waitingForPlayers(store.state),
            isNewGame(store.state),
            getPlayers(store.state)),
        distinct: true,
        builder: (context, viewModel) {
          if (!viewModel.roomIsAvailable) {
            debugPrint('Waiting for room...');
            return loading();
          }

          if (!viewModel.rolesHaveBeenChosen) {
            return RolesSelection(_store);
          }

          if (viewModel.waitingForPlayers) {
            return _waitingForPlayers(viewModel.playersSoFar, getRoom(_store.state).numPlayers);
          }

          if (viewModel.isNewGame) {
            debugPrint('Initialising game...');
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
        builder: (context, gameIsReady) =>
            gameIsReady ? SecretBoard(_store, footer(false)) : _loadingScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        dynamicBackground(_controller),
        PageView(
          controller: _controller,
          children: [
            Scaffold(
              resizeToAvoidBottomPadding: false,
              backgroundColor: Colors.transparent,
              body: _mainBoard(),
            ),
            Scaffold(
              resizeToAvoidBottomPadding: false,
              backgroundColor: Colors.transparent,
              endDrawer: isDebugMode() ? Drawer(child: ReduxDevTools<GameModel>(_store)) : null,
              body: _secretBoard(),
            ),
          ],
        ),
      ],
    );
  }
}

class LoadingScreenViewModel {
  final bool roomIsAvailable;
  final bool rolesHaveBeenChosen;
  final bool waitingForPlayers;
  final bool isNewGame;
  final List<Player> playersSoFar;

  LoadingScreenViewModel._(this.roomIsAvailable, this.rolesHaveBeenChosen, this.waitingForPlayers,
      this.isNewGame, this.playersSoFar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingScreenViewModel &&
          roomIsAvailable == other.roomIsAvailable &&
          rolesHaveBeenChosen == other.rolesHaveBeenChosen &&
          waitingForPlayers == other.waitingForPlayers &&
          isNewGame == other.isNewGame &&
          playersSoFar == other.playersSoFar;

  @override
  int get hashCode =>
      roomIsAvailable.hashCode ^
      rolesHaveBeenChosen.hashCode ^
      waitingForPlayers.hashCode ^
      isNewGame.hashCode ^
      playersSoFar.hashCode;

  @override
  String toString() {
    return 'LoadingScreenViewModel{roomIsAvailable: $roomIsAvailable,'
        ' rolesHaveBeenChosen: $rolesHaveBeenChosen,'
        ' waitingForPlayers: $waitingForPlayers,'
        ' isNewGame: $isNewGame,'
        ' playersSoFar: $playersSoFar}';
  }
}

class MainBoardViewModel {
  final Haunt currentHaunt;
  final Round currentRound;
  final LocalActions localActions;
  final bool biddingComplete;
  final bool resolvingAuction;
  final bool hauntIsActive;

  MainBoardViewModel._({
    @required this.currentHaunt,
    @required this.currentRound,
    @required this.localActions,
    @required this.biddingComplete,
    @required this.resolvingAuction,
    @required this.hauntIsActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainBoardViewModel &&
          runtimeType == other.runtimeType &&
          currentHaunt == other.currentHaunt &&
          currentRound == other.currentRound &&
          localActions == other.localActions &&
          biddingComplete == other.biddingComplete &&
          resolvingAuction == other.resolvingAuction &&
          hauntIsActive == other.hauntIsActive;

  @override
  int get hashCode =>
      currentHaunt.hashCode ^
      currentRound.hashCode ^
      localActions.hashCode ^
      biddingComplete.hashCode ^
      resolvingAuction.hashCode ^
      hauntIsActive.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{currentHaunt: $currentHaunt, currentRound: $currentRound, localActions: $localActions, biddingComplete: $biddingComplete, resolvingAuction: $resolvingAuction, hauntIsActive: $hauntIsActive}';
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
