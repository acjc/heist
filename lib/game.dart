part of heist;

class Game extends StatefulWidget {
  final String code;

  Game(this.code);

  @override
  State<StatefulWidget> createState() => new GameState(code);
}

class GameState extends State<Game> {
  final String code;

  GameState(this.code);

  Widget _buildRoomList() {
    return new Expanded(
        child: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('rooms').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return new Text('Loading...');
        }

        final tiles = snapshot.data.documents.map((DocumentSnapshot document) {
          Room room = new Room.fromJson(document.data);
          return new ListTile(
            title: new Text(room.code),
            subtitle: new Text(room.createdAt.toString()),
          );
        }).toList();

        final dividedTiles = ListTile
            .divideTiles(
              context: context,
              tiles: tiles,
            )
            .toList();

        return new ListView(
          children: dividedTiles,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Room: $code"),
      ),
      body: new Column(
        children: [
          _buildRoomList(),
          new Card(
            elevation: 2.0,
            child: new ListTile(
              title: new Text(code),
              subtitle: new Text('Game state'),
            ),
          )
        ],
      ),
    );
  }
}
