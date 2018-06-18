part of heist;

class Game extends StatefulWidget {
  final Store<GameModel> store;

  Game(this.store);

  @override
  State<StatefulWidget> createState() {
    return new GameState(store);
  }
}

class GameState extends State<Game> {
  static const EdgeInsets _padding = const EdgeInsets.all(24.0);
  static const TextStyle _textStyle = const TextStyle(fontSize: 16.0);

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
      style: _textStyle,
    ));
  }

  Widget _mainBoardBodyContent(GameModel viewModel) {
    return new ListTile(
      title: new Text(
        "${viewModel.room.code} - ${viewModel.room.numPlayers} players",
        style: _textStyle,
      ),
    );
  }

  Widget _secretBoardBodyContent(GameModel viewModel) {
    Player me = viewModel.me();
    return new ListTile(
      title: new Text(
        "${me.name} (${me.role})",
        style: _textStyle,
      ),
    );
  }

  Widget _boardBody(Store<GameModel> store, GameModel viewModel, Widget boardBodyContent) {
    if (!viewModel.roomIsAvailable()) {
      return _loading();
    }

    if (viewModel.waitingForPlayers()) {
      return new Center(
          child: new Text(
        "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
        style: _textStyle,
      ));
    }

    if (viewModel.isNewGame()) {
      return new Center(
          child: new Text(
        "Assigning roles...",
        style: _textStyle,
      ));
    }

    if (!viewModel.ready()) {
      return _loading();
    }

    return boardBodyContent;
  }

  Widget _mainBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        converter: (store) => store.state,
        distinct: true,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                elevation: 2.0,
                child: _boardBody(store, viewModel, _mainBoardBodyContent(viewModel)),
              ),
            ));
  }

  Widget _secretBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        converter: (store) => store.state,
        distinct: true,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                elevation: 2.0,
                child: _boardBody(store, viewModel, _secretBoardBodyContent(viewModel)),
              ),
            ));
  }

  Widget _playerInfo(Store<GameModel> store) {
    return new StoreConnector<GameModel, _PlayerInfoViewModel>(
        converter: (store) =>
            new _PlayerInfoViewModel(store.state.me(), store.state.getCurrentBalance()),
        distinct: true,
        builder: (context, viewModel) {
          if (viewModel.me == null) {
            return new Container();
          }
          return new Card(
            elevation: 2.0,
            child: new Container(
              padding: _padding,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new Text(
                    viewModel.me.name,
                    style: _textStyle,
                  ),
                  new Text(
                    viewModel.balance.toString(),
                    style: _textStyle,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _gameHistory() {
    return new StoreConnector<GameModel, List<Heist>>(
        converter: (store) => store.state.heists,
        distinct: true,
        builder: (context, viewModel) {
          if (viewModel.isEmpty) {
            return new Container();
          }
          return new Card(
              elevation: 2.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: new List.generate(5, (i) {
                  int price = i < viewModel.length ? viewModel[i].price : -1;
                  return new Container(
                    padding: _padding,
                    child: new Text("$price"),
                  );
                }),
              ));
        });
  }

  Widget _tabView(Store<GameModel> store) {
    return new TabBarView(
      children: [
        new Column(children: [_mainBoard(store), _gameHistory()]),
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
  store.dispatch(new UpdateStateAction<Set<Player>>(new Set()));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}

class _PlayerInfoViewModel {
  final Player me;
  final int balance;

  _PlayerInfoViewModel(this.me, this.balance);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PlayerInfoViewModel && me == other.me && balance == other.balance;

  @override
  int get hashCode => me.hashCode ^ balance.hashCode;

  @override
  String toString() {
    return '_PlayerInfoViewModel{me: $me, balance: $balance}';
  }
}
