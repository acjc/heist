library heist;

import 'dart:math';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

part 'db/database.dart';
part 'db/database_model.dart';
part 'home_page.dart';
part 'game.dart';
part 'state.dart';
part 'middleware/middleware.dart';
part 'reducers/reducers.dart';
part 'reducers/room_reducers.dart';
part 'reducers/player_reducers.dart';
part 'reducers/heist_reducers.dart';
part 'reducers/round_reducers.dart';
part 'reducers/subscription_reducers.dart';

void main() => runApp(new MyApp());

final Set<String> agentRoles = new Set.of(['LEAD_AGENT', 'AGENT_1', 'AGENT_2', 'AGENT_3']);
final Set<String> thiefRoles =
    new Set.of(['KINGPIN', 'ACCOUNTANT', 'THIEF_1', 'THIEF_2', 'THIEF_3', 'THIEF_4']);
final Set<String> allRoles = new Set.of(agentRoles)..addAll(thiefRoles);

const int minPlayers = 5;
const int maxPlayers = 10;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

String installId() {
  return 'test_install_id';
}

Store<GameModel> createStore(FirestoreDb db) {
  return new Store<GameModel>(
    gameModelReducer,
    initialState: new GameModel.initial(db, minPlayers),
    middleware: createMiddleware(),
    distinct: true,
  );
}

class MyApp extends StatelessWidget {
  final store = createStore(new FirestoreDb(Firestore.instance));

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
