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
import 'package:heist/widget/background.dart';
import 'package:heist/widget/create_room_page.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget enterNameForm(BuildContext context, Store<GameModel> store, GlobalKey<FormState> key) =>
    Form(
        key: key,
        child: TextFormField(
            initialValue: isDebugMode() ? 'Mordred' : getPlayerName(store.state),
            maxLength: 12,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).enterYourName,
            ),
            style: Theme.of(context).textTheme.headline,
            autocorrect: false,
            textAlign: TextAlign.center,
            validator: (value) => value == null || value.isEmpty
                ? AppLocalizations.of(context).pleaseEnterAName
                : null,
            onSaved: (value) => store.dispatch(SavePlayerNameAction(value))));

class HomePage extends StatelessWidget {
  static final _onlyLetters = new RegExp(r"[A-Za-z]");
  static final TextInputFormatter _capitalFormatter = TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()));

  Widget _enterRoomButton(BuildContext context, Store<GameModel> store) => new RaisedButton(
        child: Text(
          AppLocalizations.of(context).joinGame,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () async {
          FormState enterCodeState = Keys.homePageCodeKey.currentState;
          FormState enterNameState = Keys.homePageNameKey.currentState;
          if (enterCodeState.validate()) {
            enterCodeState.save();
            enterNameState.save();
            store.dispatch(
                new ValidateRoomAction(context, () => new Connectivity().checkConnectivity()));
          }
        },
      );

  Form _enterCodeForm(BuildContext context, Store<GameModel> store) => Form(
      key: Keys.homePageCodeKey,
      child: TextFormField(
          initialValue: isDebugMode() ? 'ABCD' : getRoomCode(store.state),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).enterRoomCode,
          ),
          style: Theme.of(context).textTheme.headline,
          maxLength: 4,
          autocorrect: false,
          textAlign: TextAlign.center,
          inputFormatters: [
            WhitelistingTextInputFormatter(_onlyLetters),
            _capitalFormatter,
          ],
          validator: (value) => value.length != 4 ? AppLocalizations.of(context).invalidCode : null,
          onSaved: (value) {
            store.dispatch(SetRoomCodeAction(value));
            store.dispatch(SaveRoomCodeAction(value));
          }));

  Widget _body(Store<GameModel> store) => StoreConnector<GameModel, bool>(
        onInit: (_) => SystemChrome.setEnabledSystemUIOverlays([]),
        distinct: true,
        converter: (store) => requestInProcess(store.state, Request.ValidatingRoom),
        builder: (context, validatingRoom) {
          if (validatingRoom) {
            return loading();
          }
          return Center(
            child: Card(
              margin: paddingLarge,
              elevation: 2.0,
              child: Padding(
                padding: paddingLarge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: enterNameForm(context, store, Keys.homePageNameKey),
                    ),
                    Column(
                      children: [
                        _enterCodeForm(context, store),
                        _enterRoomButton(context, store),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      endDrawer: isDebugMode() ? Drawer(child: ReduxDevTools<GameModel>(store)) : null,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRoomPage()))),
      body: Stack(
        children: [
          staticBackground(),
          _body(store),
        ],
      ),
    );
  }
}
