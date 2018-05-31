part of heist;

class HomePage extends StatelessWidget {
  static const EdgeInsets _padding = const EdgeInsets.all(16.0);
  static const TextStyle _buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 16.0);

  final _enterRoomFormKey = new GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    store.dispatch(new UnmarkAsBusyAction());

    Widget numPlayersText = new StoreConnector<GameModel, int>(
        converter: (store) => store.state.room.numPlayers,
        builder: (context, int numPlayers) {
          return new Container(
            padding: _padding,
            child: new Text(
              numPlayers.toString(),
              style: const TextStyle(
                fontSize: 32.0,
              ),
            ),
          );
        });

    Widget createRoomButton = new Container(
      padding: _padding,
      child: new RaisedButton(
        child: const Text('CREATE ROOM', style: _buttonTextStyle),
        onPressed: () => store.dispatch(new CreateRoomAction()),
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
                context, Icons.arrow_back, () => store.dispatch(new DecrementNumPlayersAction())),
            numPlayersText,
            _buildArrowColumn(
                context, Icons.arrow_forward, () => store.dispatch(new IncrementNumPlayersAction()))
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
            inputFormatters: [
              new WhitelistingTextInputFormatter(_onlyLetters),
              _capitalFormatter,
            ],
            validator: (value) =>
                value.length != 4 ? 'Invalid code' : null, // TODO: validate room exists and is open
            onSaved: (value) => store.dispatch(new EnterCodeAction(value))));

    void _enterRoom() {
      FormState enterRoomState = _enterRoomFormKey.currentState;
      if (enterRoomState.validate()) {
        enterRoomState.save();
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new Game()));
      }
    }

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
      children: [numPlayers, existingRoom],
    );
  }
}
