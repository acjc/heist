import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/keys.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/background.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/home_page.dart';
import 'package:redux/redux.dart';

class CreateRoomPage extends StatelessWidget {
  Widget _numPlayersSelector(Store<GameModel> store) => StoreConnector<GameModel, int>(
      distinct: true,
      converter: (store) => store.state.room.numPlayers,
      builder: (context, int numPlayers) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            iconWidget(
              context,
              Icons.arrow_back,
              () => store.dispatch(DecrementNumPlayersAction()),
              numPlayers > minPlayers,
            ),
            Text(numPlayers.toString(), style: bigNumberTextStyle),
            iconWidget(
              context,
              Icons.arrow_forward,
              () => store.dispatch(IncrementNumPlayersAction()),
              numPlayers < maxPlayers,
            ),
          ],
        );
      });

  Widget _createRoomButton(BuildContext context, Store<GameModel> store) => RaisedButton(
        child: Text(
          AppLocalizations.of(context).createRoom,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () async {
          FormState enterNameState = Keys.createRoomPageNameKey.currentState;
          if (enterNameState.validate()) {
            enterNameState.save();
            store.dispatch(CreateRoomAction(context, () => Connectivity().checkConnectivity()));
          }
        },
      );

  Widget _body(BuildContext context, Store<GameModel> store) => Center(
        child: Card(
          elevation: 2.0,
          margin: paddingLarge,
          child: Padding(
            padding: paddingLarge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: enterNameForm(context, store, Keys.createRoomPageNameKey),
                ),
                Padding(
                  padding: paddingMedium,
                  child: Text(
                    AppLocalizations.of(context).chooseNumberOfPlayers,
                    style: infoTextStyle,
                  ),
                ),
                _numPlayersSelector(store),
                _createRoomButton(context, store),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return Stack(
      children: [
        staticBackground(),
        Scaffold(
          resizeToAvoidBottomPadding: false,
          endDrawer: isDebugMode() ? Drawer(child: ReduxDevTools<GameModel>(store)) : null,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          body: _body(context, store),
        ),
      ],
    );
  }
}
