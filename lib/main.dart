library heist;

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:reselect/reselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'db/database.dart';
part 'db/database_model.dart';
part 'heist_definitions.dart';
part 'middleware/bidding_middleware.dart';
part 'middleware/game_middleware.dart';
part 'middleware/gifting_middleware.dart';
part 'middleware/heist_middleware.dart';
part 'middleware/middleware.dart';
part 'middleware/room_middleware.dart';
part 'middleware/round_end_middleware.dart';
part 'middleware/team_picker_middleware.dart';
part 'reducers/bid_amount_reducers.dart';
part 'reducers/gift_amount_reducers.dart';
part 'reducers/heist_reducers.dart';
part 'reducers/player_reducers.dart';
part 'reducers/reducers.dart';
part 'reducers/request_reducers.dart';
part 'reducers/room_reducers.dart';
part 'reducers/round_reducers.dart';
part 'reducers/subscription_reducers.dart';
part 'role.dart';
part 'selectors/bidding_selectors.dart';
part 'selectors/gifting_selectors.dart';
part 'selectors/heist_selectors.dart';
part 'selectors/player_selectors.dart';
part 'selectors/selectors.dart';
part 'selectors/setup_selectors.dart';
part 'selectors/team_picker_selectors.dart';
part 'state.dart';
part 'widget/bidding.dart';
part 'widget/common.dart';
part 'widget/decision.dart';
part 'widget/endgame.dart';
part 'widget/game.dart';
part 'widget/game_history.dart';
part 'widget/gifting.dart';
part 'widget/heist_end.dart';
part 'widget/home_page.dart';
part 'widget/player_info.dart';
part 'widget/round_end.dart';
part 'widget/selection_board.dart';
part 'widget/team_picker.dart';

void main() => runApp(new MyApp(Firestore.instance));

const int minPlayers = 5;
const int maxPlayers = 10;

const String PrefInstallId = 'INSTALL_ID';

const String DebugInstallId = 'test_install_id';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

bool isDebugMode() {
  bool debugMode = false;
  assert(debugMode = true);
  return debugMode;
}

DateTime now() {
  return new DateTime.now().toUtc();
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
          navigatorKey: navigatorKey,
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
