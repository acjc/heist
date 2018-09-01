import 'dart:async';

import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/middleware/middleware.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/form_reducers.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';

import 'mock_firestore_db.dart';

Future<void> handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

String uuid() {
  return new Uuid().v4();
}

Future<void> addOtherPlayers(Store<GameModel> store) async {
  for (int i = 0; i < store.state.room.numPlayers - 1; i++) {
    await store.state.db
        .upsertPlayer(new Player(installId: uuid(), name: uuid()), store.state.room.id);
  }
}

Future<Store<GameModel>> initGame() async {
  FirestoreDb db = new MockFirestoreDb.empty();
  Store<GameModel> store = createStore(db, minPlayers);
  store.dispatch(new SavePlayerNameAction('_name'));
  await handle(store, new CreateRoomAction());
  await new LoadGameAction().loadGame(store);
  await handle(store, new JoinGameAction());
  await addOtherPlayers(store);
  await handle(store, new SetUpNewGameAction());
  return store;
}
