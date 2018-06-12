part of heist;

const EdgeInsets padding = const EdgeInsets.all(24.0);
const TextStyle textStyle = const TextStyle(fontSize: 16.0);

class Game extends StatelessWidget {
  Widget _loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: textStyle,
    ));
  }

  Widget _loadingScreen(GameModel viewModel) {
    if (!viewModel.roomIsAvailable()) {
      return _loading();
    }

    if (viewModel.waitingForPlayers()) {
      return new Center(
          child: new Text(
        "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
        style: textStyle,
      ));
    }

    if (viewModel.isNewGame()) {
      return new Center(
          child: new Text(
        "Assigning roles...",
        style: textStyle,
      ));
    }

    return _loading();
  }

  Widget _currentGameComponent(GameModel viewModel) {
    Player me = viewModel.me();
    return new ListTile(
      title: new Text(
        "${viewModel.room.code} - ${viewModel.room.numPlayers} players",
        style: textStyle,
      ),
      subtitle: new Text(
        "${me.name} (${me.role})",
        style: textStyle,
      ),
    );
  }

  Widget _mainBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        onInit: (store) => store.dispatch(new LoadGameAction()),
        onDispose: (store) => _resetGameStore(store),
        distinct: true,
        converter: (store) => store.state,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                elevation: 2.0,
                child: viewModel.ready()
                    ? _currentGameComponent(viewModel)
                    : _loadingScreen(viewModel),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
        ),
        endDrawer: isDebugMode()
            ? new Drawer(child: new ReduxDevTools<GameModel>(store))
            : null,
        body: new Column(children: [_playerInfo(store), _mainBoard(store), _gameHistory(store)]));
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
