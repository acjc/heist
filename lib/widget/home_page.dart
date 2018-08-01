import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/player_reducers.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class HomePage extends StatelessWidget {
  final _enterNameFormKey = new GlobalKey<FormState>();
  final _enterCodeFormKey = new GlobalKey<FormState>();

  Widget _buildTitle(String title) {
    return new Container(
      padding: paddingMedium,
      child: new Text(
        title,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  static final _onlyLetters = new RegExp(r"[A-Za-z]");
  static final TextInputFormatter _capitalFormatter = TextInputFormatter
      .withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()));

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);

    Widget numPlayersText = new StoreConnector<GameModel, int>(
        distinct: true,
        converter: (store) => store.state.room.numPlayers,
        builder: (context, int numPlayers) {
          return new Text(
            numPlayers.toString(),
            style: const TextStyle(
              fontSize: 32.0,
            ),
          );
        });

    Widget rolesText = new StoreConnector<GameModel, Set<String>>(
        distinct: true,
        converter: (store) => store.state.room.roles,
        builder: (context, Set<String> roles) {
          return new Container(
            padding: paddingMedium,
            child: new Text(
              'Roles: ${roles?.toString()}',
              style: infoTextStyle,
            ),
          );
        });

    Widget createRoomButton = new RaisedButton(
      child: const Text('CREATE ROOM', style: buttonTextStyle),
      onPressed: () {
        FormState enterNameState = _enterNameFormKey.currentState;
        if (enterNameState.validate()) {
          enterNameState.save();
          store.dispatch(new CreateRoomAction());
        }
      },
    );

    Form enterNameForm = new Form(
        key: _enterNameFormKey,
        child: new TextFormField(
            initialValue: isDebugMode() ? 'Mordred' : null,
            decoration: new InputDecoration(
              labelText: 'Enter your name',
              isDense: true,
            ),
            style: new TextStyle(color: Colors.black87, fontSize: 24.0),
            autocorrect: false,
            textAlign: TextAlign.center,
            validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
            onSaved: (value) => store.dispatch(new SetPlayerNameAction(value))));

    Widget createRoom = new Container(
      padding: paddingMedium,
      child: new Column(
        children: [
          enterNameForm,
          _buildTitle('Choose number of players:'),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              iconWidget(
                  context, Icons.arrow_back, () => store.dispatch(new DecrementNumPlayersAction())),
              numPlayersText,
              iconWidget(context, Icons.arrow_forward,
                  () => store.dispatch(new IncrementNumPlayersAction()))
            ],
          ),
          rolesText,
          createRoomButton,
        ],
      ),
    );

    Form enterCodeForm = new Form(
        key: _enterCodeFormKey,
        child: new TextFormField(
            initialValue: isDebugMode() ? 'ABCD' : null,
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
            validator: (value) => value.length != 4 ? 'Invalid code' : null,
            onSaved: (value) => store.dispatch(new SetRoomCodeAction(value))));

    void _enterRoom() {
      FormState enterCodeState = _enterCodeFormKey.currentState;
      FormState enterNameState = _enterNameFormKey.currentState;
      if (enterCodeState.validate()) {
        enterCodeState.save();
        enterNameState.save();
        store.dispatch(new ValidateRoomAction(context));
      }
    }

    Widget enterRoomButton = new RaisedButton(
      child: const Text('ENTER ROOM', style: buttonTextStyle),
      onPressed: _enterRoom,
    );

    Widget existingRoom = new Container(
      padding: paddingMedium,
      child: new Column(
        children: [
          enterCodeForm,
          enterRoomButton,
        ],
      ),
    );

    return new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.ValidatingRoom),
      distinct: true,
      builder: (context, validatingRoom) {
        if (validatingRoom) {
          return loading();
        }

        return new Column(
          children: [createRoom, existingRoom],
        );
      },
    );
  }
}
