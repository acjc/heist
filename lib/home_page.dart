part of heist;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  int _numPlayers = _minPlayers;

  int _getCapitalLetterOrdinal(Random random) {
    return random.nextInt(26) + 65; // 65 is 'A' in ASCII
  }

  String _generateRoomCode() {
    Random random = new Random();
    List<int> numbers = [
      _getCapitalLetterOrdinal(random),
      _getCapitalLetterOrdinal(random),
      _getCapitalLetterOrdinal(random),
      _getCapitalLetterOrdinal(random)
    ];
    return new String.fromCharCodes(numbers);
  }

  void _createRoom() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // TODO: get the right roles
      final Set<String> roles = new Set.from(['ACCOUNTANT', 'KINGPIN', 'LEAD_AGENT']);

      // create the room in the database
      Firestore.instance.collection('rooms').document().setData(new Room(
              appVersion: packageInfo.version,
              code: _generateRoomCode(),
              createdAt: new DateTime.now(),
              numPlayers: _numPlayers,
              roles: roles)
          .toJson());
      Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Your room has been created"),
          ));
    });
  }

  Column _buildArrowColumn(BuildContext context, IconData icon, Function onPressed) {
    Color color = Theme.of(context).primaryColor;
    return new Column(
      children: [
        new IconButton(
          iconSize: 64.0,
          onPressed: onPressed,
          icon: new Icon(icon, color: color),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget numPlayersText = new Container(
      padding: const EdgeInsets.all(32.0),
      child: new Text(
        _numPlayers.toString(),
        style: const TextStyle(
          fontSize: 32.0,
        ),
      ),
    );

    Widget numPlayersTitle = new Container(
      padding: const EdgeInsets.all(32.0),
      child: const Text(
        "Choose number of players:",
        style: const TextStyle(fontSize: 16.0),
      ),
    );

    Widget numPlayers = new Column(
      children: [
        numPlayersTitle,
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildArrowColumn(
                context,
                Icons.arrow_back,
                () => setState(() {
                      if (_numPlayers > _minPlayers) _numPlayers--;
                    })),
            numPlayersText,
            _buildArrowColumn(
                context,
                Icons.arrow_forward,
                () => setState(() {
                      if (_numPlayers < _maxPlayers) _numPlayers++;
                    }))
          ],
        )
      ],
    );

    Widget createRoomButton = new Container(
      padding: const EdgeInsets.all(32.0),
      child: new RaisedButton(
        child:
            const Text('CREATE ROOM', style: const TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _createRoom,
        color: Theme.of(context).primaryColor,
      ),
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [numPlayers, createRoomButton, _buildRoomList()],
    );
  }

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
}
