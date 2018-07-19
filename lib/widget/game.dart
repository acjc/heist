import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/request_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/reducers/subscription_reducers.dart';
import 'package:redux/redux.dart';

import 'bidding.dart';
import 'common.dart';
import 'decision.dart';
import 'endgame.dart';
import 'game_history.dart';
import 'gifting.dart';
import 'heist_end.dart';
import 'player_info.dart';
import 'round_end.dart';
import 'selection_board.dart';
import 'team_picker.dart';

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

  GameState(this._store);

  @override
  void initState() {
    super.initState();
    _store.dispatch(new LoadGameAction());
  }

  @override
  void dispose() {
    resetGameStore(_store);
    super.dispose();
  }

  Widget _resolveEndgame(bool completingGame) {
    if (!(getRoom(_store.state).completedAt == null) && !completingGame) {
      _store.dispatch(new CompleteGameAction());
    }
    return endgame(_store);
  }

  Widget _resolveAuctionWinners(bool resolvingAuction) {
    if (amOwner(_store.state) && !resolvingAuction) {
      _store.dispatch(new ResolveAuctionWinnersAction());
    }
    return centeredMessage('Resolving auction...');
  }

  Widget _biddingAndGifting(Store<GameModel> store) {
    List<Widget> children = [bidding(store)];
    if (!isAuction(store.state)) {
      children.add(selectionBoard(_store));
    }
    children.add(gifting(store));
    return new Column(children: children);
  }

  Widget _gameLoop(MainBoardViewModel viewModel) {
    // team picking (not needed for auctions)
    if (!isAuction(_store.state) && viewModel.waitingForTeam) {
      return isMyGo(_store.state) ? teamPicker(_store) : waitForTeam(_store);
    }

    // bidding
    if (!viewModel.biddingComplete) {
      return _biddingAndGifting(_store);
    }

    // resolve round
    if (!viewModel.roundComplete) {
      return roundEnd(_store);
    }

    // resolve auction
    if (isAuction(_store.state) && viewModel.waitingForTeam) {
      return _resolveAuctionWinners(viewModel.resolvingAuction);
    }

    // active heist
    if (viewModel.heistIsActive) {
      return goingOnHeist(_store.state) ? makeDecision(context, _store) : observeHeist(_store);
    }

    // go to next heist
    if (viewModel.heistDecided && !viewModel.heistComplete) {
      return heistEnd(_store);
    }

    return null;
  }

  Widget _mainBoardBody() => new StoreConnector<GameModel, MainBoardViewModel>(
      converter: (store) {
        Heist heist = currentHeist(store.state);
        Round round = currentRound(store.state);
        return new MainBoardViewModel._(
          waitingForTeam: !round.teamSubmitted,
          biddingComplete: biddingComplete(store.state),
          resolvingAuction: requestInProcess(store.state, Request.ResolvingAuction),
          roundComplete: round.complete,
          heistIsActive: heistIsActive(store.state),
          heistDecided: heist.allDecided,
          heistComplete: heist.complete,
        );
      },
      distinct: true,
      builder: (context, viewModel) {
        Widget child = _gameLoop(viewModel);
        if (child == null) {
          return loading();
        }
        return new SingleChildScrollView(
          child: child,
        );
      });

  Widget _secretBoardBody() => new StoreConnector<GameModel, Player>(
      converter: (store) => getSelf(store.state),
      distinct: true,
      builder: (context, me) =>
          new Card(elevation: 2.0, child: new Column(children: getSecretListTiles(me))));

  List<ListTile> getSecretListTiles(Player me) {
    List<ListTile> basicTiles = [
      new ListTile(
        title: new Text(
          "You are in team ${getTeam(me.role).toString()}",
          style: infoTextStyle,
        ),
      ),
      new ListTile(
        title: new Text(
          "Your role is ${getDisplayName(me.role)}",
          style: infoTextStyle,
        ),
      ),
    ];

    // show the identities the player knows, if any
    if (getKnownIds(me.role) != null) {
      basicTiles.add(new ListTile(
        // TODO
        title: new Text(
          "You also know these identities:",
          style: infoTextStyle,
        ),
      ));
      basicTiles.add(new ListTile(
        title: new Text(
          "${_getFormattedKnownIds(_store.state, getKnownIds(me.role))}",
          style: infoTextStyle,
        ),
      ));
    }

    return basicTiles;
  }

  String _getFormattedKnownIds(GameModel gameModel, Set<String> knownIds) {
    String formattedKnownIds = "";
    knownIds?.forEach((roleId) {
      formattedKnownIds +=
          getPlayerByRoleId(gameModel, roleId).name + " is the " + getDisplayName(roleId) + "\n";
    });
    return formattedKnownIds;
  }

  Widget _loadingScreen() => new StoreConnector<GameModel, LoadingScreenViewModel>(
        converter: (store) => new LoadingScreenViewModel._(roomIsAvailable(store.state),
            waitingForPlayers(store.state), isNewGame(store.state), getPlayers(store.state).length),
        distinct: true,
        builder: (context, viewModel) {
          if (!viewModel.roomIsAvailable) {
            return loading();
          }

          if (viewModel.waitingForPlayers) {
            return centeredMessage(
                'Waiting for players: ${viewModel.playersSoFar} / ${getRoom(_store.state).numPlayers}');
          }

          if (viewModel.isNewGame) {
            return centeredMessage('Assigning roles...');
          }

          return loading();
        },
      );

  Widget _mainBoard() => new StoreConnector<GameModel, GameActiveViewModel>(
      converter: (store) => new GameActiveViewModel._(gameIsReady(store.state),
          gameOver(store.state), requestInProcess(store.state, Request.CompletingGame)),
      distinct: true,
      builder: (context, viewModel) {
        if (!viewModel.gameIsReady) {
          return _loadingScreen();
        }
        if (viewModel.gameOver) {
          return _resolveEndgame(viewModel.completingGame);
        }
        return new Stack(
          children: [
            _mainBoardBody(),
            new Positioned(
              child: gameHistory(_store),
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
            ),
          ],
        );
      });

  Widget _secretBoard() => new StoreConnector<GameModel, bool>(
      converter: (store) => gameIsReady(store.state),
      distinct: true,
      builder: (context, gameIsReady) => new Expanded(
            child: gameIsReady ? _secretBoardBody() : _loadingScreen(),
          ));

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${getRoom(_store.state).code}"),
          bottom: new TabBar(
            tabs: [
              new Tab(text: 'GAME'),
              new Tab(text: 'SECRET'),
            ],
          ),
        ),
        endDrawer: isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(_store)) : null,
        body: new TabBarView(
          children: [
            _mainBoard(),
            new Column(children: [playerInfo(_store), _secretBoard()]),
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
  final int playersSoFar;

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
  final bool waitingForTeam;
  final bool biddingComplete;
  final bool resolvingAuction;
  final bool roundComplete;
  final bool heistIsActive;
  final bool heistDecided;
  final bool heistComplete;

  MainBoardViewModel._(
      {@required this.waitingForTeam,
      @required this.biddingComplete,
      @required this.resolvingAuction,
      @required this.roundComplete,
      @required this.heistIsActive,
      @required this.heistDecided,
      @required this.heistComplete});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainBoardViewModel &&
          runtimeType == other.runtimeType &&
          waitingForTeam == other.waitingForTeam &&
          biddingComplete == other.biddingComplete &&
          resolvingAuction == other.resolvingAuction &&
          roundComplete == other.roundComplete &&
          heistIsActive == other.heistIsActive &&
          heistDecided == other.heistDecided &&
          heistComplete == other.heistComplete;

  @override
  int get hashCode =>
      waitingForTeam.hashCode ^
      biddingComplete.hashCode ^
      resolvingAuction.hashCode ^
      roundComplete.hashCode ^
      heistIsActive.hashCode ^
      heistDecided.hashCode ^
      heistComplete.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{waitingForTeam: $waitingForTeam, biddingComplete: $biddingComplete, resolvingAuction: $resolvingAuction, roundComplete: $roundComplete, heistIsActive: $heistIsActive, heistDecided: $heistDecided, heistComplete: $heistComplete}';
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
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(new Room.initial(isDebugMode() ? 2 : minPlayers)));
  store.dispatch(new UpdateStateAction<List<Player>>([]));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}
