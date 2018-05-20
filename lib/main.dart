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

part 'database.dart';
part 'database_model.dart';
part 'home_page.dart';
part 'game.dart';
part 'state.dart';
part 'middleware/middleware.dart';
part 'middleware/room_middleware.dart';
part 'reducers/reducers.dart';
part 'reducers/room_reducers.dart';
part 'reducers/player_reducers.dart';
part 'reducers/heist_reducers.dart';
part 'reducers/round_reducers.dart';

void main() => runApp(new MyApp());

const int _minPlayers = 5;
const int _maxPlayers = 10;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final store = new Store<GameModel>(
    gameModelReducer,
    initialState: new GameModel.initial(_minPlayers),
    middleware: createMiddleware(),
    distinct: true,
  );

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
