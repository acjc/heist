part of heist;

class Game extends StatelessWidget {

  static const TextStyle standard = const TextStyle(fontSize: 16.0);

  Widget body(GameModel gameModel) {
    if (gameModel.players == null) {
      print('loading...');
      return new Center(child: new Text('Loading...', style: standard,));
    }
    if (gameModel.players.length < gameModel.room.numPlayers) {
      return new Center(
          child: new Text(
        "Waiting for players: ${gameModel.players.length} / ${gameModel.room.numPlayers}",
        style: standard,
      ));
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
