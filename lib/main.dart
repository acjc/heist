import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database.dart';
import 'package:heist/keys.dart';
import 'package:heist/middleware/middleware.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/home_page.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(MyApp(Firestore.instance));

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
  return DateTime.now().toUtc();
}

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  canvasColor: Colors.white, // for the bottom sheet color
  primaryColor: HeistColors.amber,
  accentColor: HeistColors.amber,
  iconTheme: const IconThemeData(color: HeistColors.amber),
  textTheme: TextTheme(
    subhead: boldTextStyle,
    body1: infoTextStyle,
    body2: infoTextStyle,
    caption: subtitleTextStyle,
    button: buttonTextStyle,
  ),
  buttonColor: HeistColors.amber,
  cardColor: Colors.black12,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueGrey,
  accentColor: HeistColors.amber,
  iconTheme: const IconThemeData(color: HeistColors.amber),
  textTheme: TextTheme(
    subhead: boldTextStyle,
    body1: infoTextStyle,
    body2: infoTextStyle,
    caption: subtitleTextStyle,
    button: buttonTextStyleLight,
  ),
  buttonColor: Colors.blueGrey,
);

Future<String> installId() async {
  if (isDebugMode()) {
    return DebugInstallId;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  String installId = preferences.getString(PrefInstallId);
  if (installId == null) {
    installId = Uuid().v4();
    await preferences.setString(PrefInstallId, installId);
  }
  return installId;
}

Store<GameModel> createStore(FirestoreDb db, [int numPlayers]) {
  if (isDebugMode()) {
    return DevToolsStore<GameModel>(
      gameModelReducer,
      initialState: GameModel.initial(db, numPlayers ?? 2),
      middleware: createMiddleware(),
      distinct: true,
    );
  }
  return Store<GameModel>(
    gameModelReducer,
    initialState: GameModel.initial(db, minPlayers),
    middleware: createMiddleware(),
    distinct: true,
  );
}

class MyApp extends StatelessWidget {
  final Store<GameModel> store;

  MyApp(Firestore firestore) : store = createStore(FirestoreDb(firestore));

  @override
  Widget build(BuildContext context) => StoreProvider(
        store: store,
        child: MaterialApp(
          navigatorKey: Keys.navigatorKey,
          title: 'Ghost Game', // can't localise this one because stuff hasn't been set up yet
          theme: darkTheme,
          home: HomePage(),
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
