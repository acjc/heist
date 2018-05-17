part of heist;

class Game extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Room"),
      ),
      body: new Column(
        children: [
          new Card(
            elevation: 2.0,
            child: new StoreConnector<GameModel, GameModel>(
                converter: (store) => store.state,
                builder: (context, GameModel gameModel) {
                  if (gameModel.player == null) {
                    return new Text('Loading...');
                  }
                  return new ListTile(
                    title: new Text(gameModel.room.code),
                    subtitle: new Text("${gameModel.player.name} (${gameModel.player.role})"),
                  );
            }),
          ),
        ],
      ),
    );
  }
}
