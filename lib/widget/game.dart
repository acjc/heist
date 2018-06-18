part of heist;

const EdgeInsets padding = const EdgeInsets.all(24.0);
const TextStyle textStyle = const TextStyle(fontSize: 16.0);

class Game extends StatefulWidget {
  final Store<GameModel> store;

  Game(this.store);

  @override
  State<StatefulWidget> createState() {
    return new GameState(store);
  }
}

class GameState extends State<Game> {
  final Store<GameModel> store;

  GameState(this.store);

  @override
  void initState() {
    super.initState();
    store.dispatch(new LoadGameAction());
  }

  @override
  void dispose() {
    _resetGameStore(store);
    super.dispose();
  }

  Widget _loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: textStyle,
    ));
  }

  Widget _mainBoardBody(GameModel viewModel) {
    return new ListTile(
      title: new Text(
        "${viewModel.room.code} - ${viewModel.room.numPlayers} players",
        style: textStyle,
      ),
    );
  }

  Widget _secretBoardBody(GameModel viewModel) {
    Player me = getSelf(viewModel);
    return new ListTile(
      title: new Text(
        "${me.name} (${me.role})",
        style: textStyle,
      ),
    );
  }

  Widget _loadingScreen(GameModel viewModel) {
    if (!roomIsAvailable(viewModel)) {
      return _loading();
    }

    if (waitingForPlayers(viewModel)) {
      return new Center(
          child: new Text(
        "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
        style: textStyle,
      ));
    }

    if (isNewGame(viewModel)) {
      return new Center(
          child: new Text(
        "Assigning roles...",
        style: textStyle,
      ));
    }

    return _loading();
  }

  Widget _mainBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        converter: (store) => store.state,
        distinct: true,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                  elevation: 2.0,
                  child: gameIsReady(viewModel)
                      ? _mainBoardBody(viewModel)
                      : _loadingScreen(viewModel)),
            ));
  }

  Widget _secretBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        converter: (store) => store.state,
        distinct: true,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                elevation: 2.0,
                child: gameIsReady(viewModel)
                    ? _secretBoardBody(viewModel)
                    : _loadingScreen(viewModel),
              ),
            ));
  }

  Widget _tabView(Store<GameModel> store) {
    return new TabBarView(
      children: [
        new Column(children: [_mainBoard(store), _gameHistory(store)]),
        new Column(children: [_playerInfo(store), _secretBoard(store)]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
          bottom: new TabBar(
            tabs: [
              new Tab(text: 'GAME'),
              new Tab(text: 'SECRET'),
            ],
          ),
        ),
        body: _tabView(store),
      ),
    );
  }
}

void _resetGameStore(Store<GameModel> store) {
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(new Room.initial()));
  store.dispatch(new UpdateStateAction<List<Player>>([]));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}
