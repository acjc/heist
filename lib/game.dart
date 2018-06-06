part of heist;

class Game extends StatelessWidget {
  static const TextStyle standard = const TextStyle(fontSize: 16.0);

  Widget _loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: standard,
    ));
  }

  Widget _waitForPlayers(Store<GameModel> store, GameModel viewModel) {
    if (!viewModel.haveJoinedGame() && !viewModel.requestInProcess(Request.JoiningGame)) {
      store.dispatch(new StartRequestAction(Request.JoiningGame));
      store.dispatch(new JoinGameAction());
    }
    return new Center(
        child: new Text(
      "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
      style: standard,
    ));
  }

  Widget _setUpNewGame(Store<GameModel> store, GameModel viewModel) {
    if (viewModel.amOwner() && !viewModel.requestInProcess(Request.CreatingNewRoom)) {
      store.dispatch(new StartRequestAction(Request.CreatingNewRoom));
      store.dispatch(new SetUpNewGameAction());
    }
    return new Center(
        child: new Text(
      "Assigning roles...",
      style: standard,
    ));
  }

  Widget _body(Store<GameModel> store, GameModel viewModel) {
    if (viewModel.isLoading()) {
      return _loading();
    }

    if (viewModel.waitingForPlayers()) {
      return _waitForPlayers(store, viewModel);
    }

    if (viewModel.requestInProcess(Request.JoiningGame)) {
      store.dispatch(new RequestCompleteAction(Request.JoiningGame));
    }

    if (viewModel.isNewGame()) {
      return _setUpNewGame(store, viewModel);
    }

    if (viewModel.requestInProcess(Request.CreatingNewRoom)) {
      store.dispatch(new RequestCompleteAction(Request.CreatingNewRoom));
    }

    if (!viewModel.isReady()) {
      return _loading();
    }

    Player me = viewModel.me();
    return new ListTile(
      title: new Text("${viewModel.room.code} - ${viewModel.room.numPlayers} players"),
      subtitle: new Text("${me.name} (${me.role})"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    // TODO: set up the game with store.onChange.listen(). UI elements should be 'dumb' as much as possible.
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
        ),
        body: new StoreConnector<GameModel, GameModel>(
          onInit: (store) => store.dispatch(new LoadGameAction()),
          onDispose: (store) => _resetGameStore(store),
          converter: (store) => store.state,
          builder: (context, viewModel) => new Card(
                elevation: 2.0,
                child: _body(store, viewModel),
              ),
        ));
  }
}

void _resetGameStore(Store<GameModel> store) {
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(store.state.room.copyWith(id: null, code: null)));
  store.dispatch(new UpdateStateAction<Set<Player>>(new Set()));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}
