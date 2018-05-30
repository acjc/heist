part of heist;

class Game extends StatelessWidget {
  static const TextStyle standard = const TextStyle(fontSize: 16.0);

  Widget loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: standard,
    ));
  }

  Widget waitForPlayers(GameModel gameModel) {
    // TODO: add self to game if not yet added
    return new Center(
        child: new Text(
      "Waiting for players: ${gameModel.players.length} / ${gameModel.room.numPlayers}",
      style: standard,
    ));
  }

  Widget setUpNewGame(GameModel gameModel) {
    if (gameModel.amOwner() && !gameModel.busy) {
      // TODO: 1) mark client as busy
      // TODO: 2) assign roles
      // TODO: 3) create first heist and round
      // TODO: 4) when done, mark client as not busy
    }
    return new Center(
        child: new Text(
          "Assigning roles...",
          style: standard,
        ));
  }

  Widget body(GameModel gameModel) {
    if (gameModel.isLoading()) {
      return loading();
    }

    if (gameModel.waitingForPlayers()) {
      return waitForPlayers(gameModel);
    }

    if (gameModel.isNewGame()) {
      return setUpNewGame(gameModel);
    }

    Player me = gameModel.me();
    return new ListTile(
      title: new Text("${gameModel.room.code} - ${gameModel.room.numPlayers} players"),
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
          builder: (context, gameModel) => new Card(
                elevation: 2.0,
                child: body(gameModel),
              ),
        ));
  }
}
