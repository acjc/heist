import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/keys.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/form_reducers.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/create_room_page.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget enterNameForm(BuildContext context, Store<GameModel> store, GlobalKey<FormState> key) =>
    new Form(
        key: key,
        child: new TextFormField(
            initialValue: isDebugMode() ? 'Mordred' : getPlayerName(store.state),
            maxLength: 12,
            decoration: new InputDecoration(
              labelText: AppLocalizations.of(context).enterYourName,
              isDense: true,
            ),
            style: new TextStyle(color: Colors.black87, fontSize: 24.0),
            autocorrect: false,
            textAlign: TextAlign.center,
            validator: (value) => value == null || value.isEmpty
                ? AppLocalizations.of(context).pleaseEnterAName
                : null,
            onSaved: (value) => store.dispatch(new SavePlayerNameAction(value))));

class HomePage extends StatelessWidget {
  static final _onlyLetters = new RegExp(r"[A-Za-z]");
  static final TextInputFormatter _capitalFormatter = TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()));

  Widget _enterRoomButton(BuildContext context, Store<GameModel> store) => new RaisedButton(
        child: Text(AppLocalizations.of(context).enterRoom, style: buttonTextStyle),
        onPressed: () async {
          FormState enterCodeState = Keys.homePageCodeKey.currentState;
          FormState enterNameState = Keys.homePageNameKey.currentState;
          if (enterCodeState.validate()) {
            enterCodeState.save();
            enterNameState.save();
            store.dispatch(new ValidateRoomAction(
                context, () => new Connectivity().checkConnectivity()));
          }
        },
      );

  Form _enterCodeForm(BuildContext context, Store<GameModel> store) => new Form(
      key: Keys.homePageCodeKey,
      child: new TextFormField(
          initialValue: isDebugMode() ? 'ABCD' : getRoomCode(store.state),
          decoration: new InputDecoration(
            labelText: AppLocalizations.of(context).enterRoomCode,
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
          validator: (value) => value.length != 4 ? AppLocalizations.of(context).invalidCode : null,
          onSaved: (value) {
            store.dispatch(new SetRoomCodeAction(value));
            store.dispatch(new SaveRoomCodeAction(value));
          }));

  Widget _body(Store<GameModel> store) => new StoreConnector<GameModel, bool>(
        converter: (store) => requestInProcess(store.state, Request.ValidatingRoom),
        distinct: true,
        builder: (context, validatingRoom) {
          if (validatingRoom) {
            return loading();
          }
          return new Padding(
            padding: paddingLarge,
            child: new Column(
              children: [
                new Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: enterNameForm(context, store, Keys.homePageNameKey),
                ),
                new Column(
                  children: [
                    _enterCodeForm(context, store),
                    _enterRoomButton(context, store),
                  ],
                )
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).homepageTitle),
      ),
      endDrawer: isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(store)) : null,
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, new MaterialPageRoute(builder: (context) => new CreateRoomPage()))),
      body: _body(store),
    );
  }
}
