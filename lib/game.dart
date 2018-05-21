part of heist;

class Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Room"),
      ),
      body: new Column(
        children: [
          new Card(
            elevation: 2.0,
            child: new StoreConnector<GameModel, GameModel>(
                onInit: (store) => store.dispatch(new EnterRoomAction()),
                onDispose: (store) => store.dispatch(new CancelSubscriptionsAction()),
                converter: (store) => store.state,
                builder: (context, GameModel gameModel) {
                  if (gameModel.player == null) {
                    return new Text('Loading...');
                  }
                  return new ListTile(
                    title:
                        new Text("${gameModel.room.code} - ${gameModel.room.numPlayers} players"),
                    subtitle: new Text("${gameModel.player.name} (${gameModel.player.role})"),
                  );
                }),
          ),
          new RaisedButton(
            child: new Text('CHANGE ROOM'),
            onPressed: () => store.dispatch(new ChangeNumPlayersAction()),
          )
        ],
      ),
    );
  }
}
