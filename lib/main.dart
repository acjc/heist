import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:heist/db/database.dart';
import 'package:heist/keys.dart';
import 'package:heist/middleware/middleware.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/home_page.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(new MyApp(Firestore.instance));

const int minPlayers = 5;
const int maxPlayers = 10;

const String PrefInstallId = 'INSTALL_ID';

const String DebugInstallId = 'test_install_id';

bool isDebugMode() {
  bool debugMode = false;
  assert(debugMode = true);
  return debugMode;
}

DateTime now() {
  return new DateTime.now().toUtc();
}

Future<String> installId() async {
  if (isDebugMode()) {
    return DebugInstallId;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  String installId = preferences.getString(PrefInstallId);
  if (installId == null) {
    installId = new Uuid().v4();
    await preferences.setString(PrefInstallId, installId);
  }
  return installId;
}

Store<GameModel> createStore(FirestoreDb db, [int numPlayers]) {
  if (isDebugMode()) {
    return new DevToolsStore<GameModel>(
      gameModelReducer,
      initialState: new GameModel.initial(db, numPlayers ?? 2),
      middleware: createMiddleware(),
      distinct: true,
    );
  }
  return new Store<GameModel>(
    gameModelReducer,
    initialState: new GameModel.initial(db, minPlayers),
    middleware: createMiddleware(),
    distinct: true,
  );
}

class MyApp extends StatelessWidget {
  final Store<GameModel> store;

  MyApp(Firestore firestore) : store = createStore(new FirestoreDb(firestore));

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.deepOrange;
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
          navigatorKey: Keys.navigatorKey,
          title: 'Heist',
          theme: new ThemeData(
            primaryColor: primaryColor,
            buttonColor: primaryColor,
            indicatorColor: Colors.white,
          ),
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text("Heist"),
            ),
            endDrawer:
                isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(store)) : null,
            body: new HomePage(),
          )),
    );
  }
}
