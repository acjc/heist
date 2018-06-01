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

  Widget _waitForPlayers(GameModel viewModel) {
    // TODO: add self to game if not yet added
    return new Center(
        child: new Text(
      "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
      style: standard,
    ));
  }

  Widget _setUpNewGame(Store<GameModel> store, GameModel viewModel) {
    print("busy = ${viewModel.busy}");
    if (viewModel.amOwner() && !viewModel.busy) {
      store.dispatch(new MarkAsBusyAction());
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
      return _waitForPlayers(viewModel);
    }

    if (viewModel.isNewGame()) {
      return _setUpNewGame(store, viewModel);
    }

    if (viewModel.busy) {
      store.dispatch(new UnmarkAsBusyAction());
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

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
        ),
        body: new StoreConnector<GameModel, GameModel>(
          onInit: (store) => store.dispatch(new LoadGameAction()),
          onDispose: (store) => store.dispatch(new CancelSubscriptionsAction()),
          converter: (store) => store.state,
          builder: (context, viewModel) => new Card(
                elevation: 2.0,
                child: _body(store, viewModel),
              ),
        ));
  }
}
