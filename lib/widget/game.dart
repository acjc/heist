part of heist;

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

  Widget _loading() {
    return centeredMessage('Loading...');
  }

  Widget _mainBoardBody(Store<GameModel> store) =>
      new StoreConnector<GameModel, MainBoardViewModel>(
          converter: (store) => new MainBoardViewModel._(
              currentHeistFunded(store.state),
              haveBeenPicked(store.state),
              !currentRound(store.state).teamSubmitted,
              isMyGo(store.state),
              biddingComplete(store.state)),
          distinct: true,
          builder: (context, viewModel) {
            if (viewModel.currentHeistFunded) { // TODO: handle auction
              if (viewModel.haveBeenPicked) { // TODO: handle auction
                return makeDecision(context, store);
              }
              return activeHeist();
            }
            if (viewModel.waitingForTeam) { // TODO: handle auction
              if (viewModel.isMyGo) {
                return teamPicker(store);
              }
              return teamIsBeingPicked();
            }
            if (!viewModel.biddingComplete) { // TODO: handle auction
              return bidding(); // TODO: handle auction
            }
            // TODO: go to new round
            return new Container();
          });

  Widget _secretBoardBody() => new StoreConnector<GameModel, Player>(
      converter: (store) => getSelf(store.state),
      distinct: true,
      builder: (context, me) => new Card(
          elevation: 2.0,
          child: new ListTile(
            title: new Text(
              "${me.name} (${me.role})",
              style: infoTextStyle,
            ),
          )));

  Widget _loadingScreen() => new StoreConnector<GameModel, LoadingScreenViewModel>(
        converter: (store) => new LoadingScreenViewModel._(
            roomIsAvailable(store.state),
            waitingForPlayers(store.state),
            isNewGame(store.state),
            getPlayers(store.state).length,
            getRoom(store.state).numPlayers),
        distinct: true,
        builder: (context, viewModel) {
          if (!viewModel.roomIsAvailable) {
            return _loading();
          }

          if (viewModel.waitingForPlayers) {
            return centeredMessage(
                'Waiting for players: ${viewModel.playersSoFar} / ${viewModel.numPlayers}');
          }

          if (viewModel.isNewGame) {
            return centeredMessage('Assigning roles...');
          }

          return _loading();
        },
      );

  Widget _mainBoard() => new StoreConnector<GameModel, bool>(
      converter: (store) => gameIsReady(store.state),
      distinct: true,
      builder: (context, gameIsReady) => new Expanded(
            child: gameIsReady ? _mainBoardBody(_store) : _loadingScreen(),
          ));

  Widget _secretBoard() => new StoreConnector<GameModel, bool>(
      converter: (store) => gameIsReady(store.state),
      distinct: true,
      builder: (context, gameIsReady) => new Expanded(
            child: gameIsReady ? _secretBoardBody() : _loadingScreen(),
          ));

  Widget _tabView() => new TabBarView(
        children: [
          new Column(children: [_mainBoard(), _gameHistory(_store)]),
          new Column(children: [_playerInfo(_store), _secretBoard()]),
        ],
      );

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
        body: _tabView(),
      ),
    );
  }
}

class LoadingScreenViewModel {
  final bool roomIsAvailable;
  final bool waitingForPlayers;
  final bool isNewGame;
  final int playersSoFar;
  final int numPlayers;

  LoadingScreenViewModel._(this.roomIsAvailable, this.waitingForPlayers, this.isNewGame,
      this.playersSoFar, this.numPlayers);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingScreenViewModel &&
          roomIsAvailable == other.roomIsAvailable &&
          waitingForPlayers == other.waitingForPlayers &&
          isNewGame == other.isNewGame &&
          playersSoFar == other.playersSoFar &&
          numPlayers == other.numPlayers;

  @override
  int get hashCode =>
      roomIsAvailable.hashCode ^
      waitingForPlayers.hashCode ^
      isNewGame.hashCode ^
      playersSoFar.hashCode ^
      numPlayers.hashCode;

  @override
  String toString() {
    return 'LoadingScreenViewModel{roomIsAvailable: $roomIsAvailable, waitingForPlayers: $waitingForPlayers, isNewGame: $isNewGame, playersSoFar: $playersSoFar, numPlayers: $numPlayers}';
  }
}

class MainBoardViewModel {
  final bool currentHeistFunded;
  final bool haveBeenPicked;
  final bool waitingForTeam;
  final bool isMyGo;
  final bool biddingComplete;

  MainBoardViewModel._(this.currentHeistFunded, this.haveBeenPicked, this.waitingForTeam,
      this.isMyGo, this.biddingComplete);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainBoardViewModel &&
          runtimeType == other.runtimeType &&
          currentHeistFunded == other.currentHeistFunded &&
          haveBeenPicked == other.haveBeenPicked &&
          waitingForTeam == other.waitingForTeam &&
          isMyGo == other.isMyGo &&
          biddingComplete == other.biddingComplete;

  @override
  int get hashCode =>
      currentHeistFunded.hashCode ^
      haveBeenPicked.hashCode ^
      waitingForTeam.hashCode ^
      isMyGo.hashCode ^
      biddingComplete.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{currentHeistFunded: $currentHeistFunded, haveBeenPicked: $haveBeenPicked, waitingForTeam: $waitingForTeam, isMyGo: $isMyGo, biddingComplete: $biddingComplete}';
  }
}

void resetGameStore(Store<GameModel> store) {
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(new Room.initial()));
  store.dispatch(new UpdateStateAction<List<Player>>([]));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}
