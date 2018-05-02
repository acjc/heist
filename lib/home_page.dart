part of heist;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  static const EdgeInsets _padding = const EdgeInsets.all(24.0);
  static const TextStyle _buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 16.0);

  int _numPlayers = _minPlayers;
  final _enterRoomFormKey = new GlobalKey<FormState>();
  String _existingRoomCode;

  int _getCapitalLetterOrdinal(Random random) {
    return random.nextInt(26) + 65; // 65 is 'A' in ASCII
  }

  String _generateRoomCode() {
    Random random = new Random();
    List<int> ordinals =
        new List.generate(4, (i) => _getCapitalLetterOrdinal(random), growable: false);
    return new String.fromCharCodes(
        ordinals); // TODO: validate codes are unique for currently open rooms
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

  Widget _buildTitle(String title) {
    return new Container(
      padding: _padding,
      child: new Text(
        title,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
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

  static final _onlyLetters = new RegExp(r"[A-Za-z]");
  static final TextInputFormatter _capitalFormatter = TextInputFormatter
      .withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()));

  void _enterRoom() {
    FormState enterRoomState = _enterRoomFormKey.currentState;
    if (enterRoomState.validate()) {
      enterRoomState.save();
      Navigator
          .of(context)
          .push(new MaterialPageRoute(builder: (context) => new Game(_existingRoomCode)));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget numPlayersText = new Container(
      padding: _padding,
      child: new Text(
        _numPlayers.toString(),
        style: const TextStyle(
          fontSize: 32.0,
        ),
      ),
    );

    Widget createRoomButton = new Container(
      padding: _padding,
      child: new RaisedButton(
        child: const Text('CREATE ROOM', style: _buttonTextStyle),
        onPressed: _createRoom,
        color: Theme.of(context).primaryColor,
      ),
    );

    Widget numPlayers = new Column(
      children: [
        _buildTitle('Choose number of players:'),
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
        ),
        createRoomButton,
      ],
    );

    Form enterRoomForm = new Form(
        key: _enterRoomFormKey,
        child: new TextFormField(
          decoration: new InputDecoration(
            labelText: 'Enter an existing room code',
            isDense: true,
          ),
          style: new TextStyle(color: Colors.black87, fontSize: 24.0),
          maxLength: 4,
          autocorrect: false,
          textAlign: TextAlign.center,
          inputFormatters: [new WhitelistingTextInputFormatter(_onlyLetters), _capitalFormatter],
          validator: (value) =>
              value.length != 4 ? 'Invalid code' : null, // TODO: validate room exists and is open
          onSaved: (value) => _existingRoomCode = value,
        ));

    Widget enterRoomButton = new Container(
      padding: _padding,
      child: new RaisedButton(
        child: const Text('ENTER ROOM', style: _buttonTextStyle),
        onPressed: _enterRoom,
        color: Theme.of(context).primaryColor,
      ),
    );

    Widget existingRoom = new Container(
      padding: _padding,
      child: new Column(
        children: [
          enterRoomForm,
          enterRoomButton,
        ],
      ),
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [numPlayers, existingRoom],
    );
  }
}
