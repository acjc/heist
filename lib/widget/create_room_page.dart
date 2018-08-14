import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/keys.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/home_page.dart';
import 'package:redux/redux.dart';

class CreateRoomPage extends StatelessWidget {
  Widget _numPlayersText() => new StoreConnector<GameModel, int>(
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

  Widget _rolesText() => new StoreConnector<GameModel, Set<String>>(
      distinct: true,
      converter: (store) => store.state.room.roles,
      builder: (context, Set<String> roles) => new Padding(
            padding: paddingMedium,
            child: new Column(
              children: new List.generate(roles.length, (i) {
                String roleId = roles.elementAt(i);
                Color color = getTeam(roleId) == Team.THIEVES ? Colors.green : Colors.red;
                return new Text(
                  roleId,
                  style: new TextStyle(fontSize: 16.0, color: color, fontWeight: FontWeight.bold),
                );
              }),
            ),
          ));

  Widget _createRoomButton(Store<GameModel> store) => new RaisedButton(
        child: const Text('CREATE ROOM', style: buttonTextStyle),
        onPressed: () {
          FormState enterNameState = Keys.createRoomPageNameKey.currentState;
          if (enterNameState.validate()) {
            enterNameState.save();
            store.dispatch(new CreateRoomAction());
          }
        },
      );

  Widget _body(BuildContext context, Store<GameModel> store) => new Padding(
        padding: paddingLarge,
        child: new Column(
          children: [
            new Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: enterNameForm(store, Keys.createRoomPageNameKey),
            ),
            new Padding(
              padding: paddingMedium,
              child: const Text(
                'Choose number of players:',
                style: infoTextStyle,
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                iconWidget(context, Icons.arrow_back,
                    () => store.dispatch(new DecrementNumPlayersAction())),
                _numPlayersText(),
                iconWidget(context, Icons.arrow_forward,
                    () => store.dispatch(new IncrementNumPlayersAction()))
              ],
            ),
            _rolesText(),
            _createRoomButton(store),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Heist: Create new room"),
      ),
      endDrawer: isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(store)) : null,
      body: _body(context, store),
    );
  }
}
