import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
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
        title: 'Heist', // can't localise this one because stuff hasn't been set up yet
        theme: new ThemeData(
          primaryColor: primaryColor,
          buttonColor: primaryColor,
          indicatorColor: Colors.white,
        ),
        home: new HomePage(),
        localizationsDelegates: [
          // app-specific localization delegate[s]
          const AppLocalizationsDelegate(),
          // provides localized strings and other values for the Material Components library
          GlobalMaterialLocalizations.delegate,
          // defines the default text direction, either left to right or right to left, for the widgets library
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('es', ''), // Spanish
          // ... other locales the app supports
        ],
      ),
    );
  }
}
