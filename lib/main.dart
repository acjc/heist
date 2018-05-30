library heist;

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

part 'database.dart';
part 'database_model.dart';
part 'game.dart';
part 'home_page.dart';
part 'middleware/middleware.dart';
part 'reducers/heist_reducers.dart';
part 'reducers/player_reducers.dart';
part 'reducers/reducers.dart';
part 'reducers/room_reducers.dart';
part 'reducers/round_reducers.dart';
part 'reducers/subscription_reducers.dart';
part 'state.dart';

void main() => runApp(new MyApp(Firestore.instance));

const int minPlayers = 5;
const int maxPlayers = 10;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Store<GameModel> createStore(FirestoreDb db) {
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
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Heist',
          theme: new ThemeData(
            primaryColor: Colors.deepOrange,
          ),
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text("Heist"),
            ),
            body: new HomePage(),
          )),
    );
  }
}
