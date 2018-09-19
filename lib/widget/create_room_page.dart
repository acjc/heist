import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
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
  Widget _numPlayersSelector(Store<GameModel> store) {
    return new StoreConnector<GameModel, int>(
        distinct: true,
        converter: (store) => store.state.room.numPlayers,
        builder: (context, int numPlayers) {
          return new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              iconWidget(
                context,
                Icons.arrow_back,
                () => store.dispatch(new DecrementNumPlayersAction()),
                numPlayers > minPlayers,
              ),
              new Text(numPlayers.toString(), style: bigNumberTextStyle),
              iconWidget(
                context,
                Icons.arrow_forward,
                () => store.dispatch(new IncrementNumPlayersAction()),
                numPlayers < maxPlayers,
              ),
            ],
          );
        });
  }

  Widget _rolesText() => new StoreConnector<GameModel, Set<String>>(
      distinct: true,
      converter: (store) => store.state.room.roles,
      builder: (context, Set<String> roles) => new Padding(
            padding: paddingMedium,
            child: new Column(
              children: new List.generate(roles.length, (i) {
                String roleId = roles.elementAt(i);
                Color color =
                    Roles.getTeam(roleId) == Team.SCARY ? HeistColors.purple : HeistColors.peach;
                return new Text(
                  Roles.getRoleDisplayName(context, roleId),
                  style: new TextStyle(fontSize: 16.0, color: color, fontWeight: FontWeight.bold),
                );
              }),
            ),
          ));

  Widget _createRoomButton(BuildContext context, Store<GameModel> store) => new RaisedButton(
        child: new Text(AppLocalizations.of(context).createRoom, style: buttonTextStyle),
        onPressed: () async {
          FormState enterNameState = Keys.createRoomPageNameKey.currentState;
          if (enterNameState.validate()) {
            enterNameState.save();
            store.dispatch(new CreateRoomAction(
                context, () => new Connectivity().checkConnectivity()));
          }
        },
      );

  Widget _body(BuildContext context, Store<GameModel> store) {
    return new Padding(
      padding: paddingLarge,
      child: new Column(
        children: [
          new Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: enterNameForm(context, store, Keys.createRoomPageNameKey),
          ),
          new Padding(
            padding: paddingMedium,
            child: new Text(
              AppLocalizations.of(context).chooseNumberOfPlayers,
              style: infoTextStyle,
            ),
          ),
          _numPlayersSelector(store),
          _rolesText(),
          _createRoomButton(context, store),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).createRoomTitle),
      ),
      endDrawer: isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(store)) : null,
      body: _body(context, store),
    );
  }
}
