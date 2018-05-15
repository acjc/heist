part of heist;

class Game extends StatefulWidget {
  final String code;

  Game(this.code);

  @override
  State<StatefulWidget> createState() => new GameState(code);
}

class GameState extends State<Game> {
  final Controller controller;

  GameState(String code) : controller = new Controller(code);

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
            child: new FutureBuilder(
                future: controller.load(),
                builder: (BuildContext context, AsyncSnapshot<GameModel> snapshot) {
                  if (!snapshot.hasData) {
                    return new Text('Loading...');
                  }

                  GameModel gameModel = snapshot.data;
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
