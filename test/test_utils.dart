import 'dart:async';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';
import 'package:heist/main.dart';

import 'mock_firestore_db.dart';

Future<void> handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

String uuid() {
  return new Uuid().v4();
}

Future<void> addOtherPlayers(Store<GameModel> store) async {
  for (int i = 0; i < store.state.room.numPlayers - 1; i++) {
    await store.state.db.upsertPlayer(
        new Player(installId: uuid(), name: uuid(), initialBalance: 8), store.state.room.id);
  }
}

Future<Store<GameModel>> initGame() async {
  FirestoreDb db = new MockFirestoreDb.empty();
  Store<GameModel> store = createStore(db);
  store.dispatch(new SetPlayerNameAction('_name'));
  await handle(store, new CreateRoomAction());
  await new LoadGameAction().loadGame(store);
  await handle(store, new JoinGameAction());
  await addOtherPlayers(store);
  await handle(store, new SetUpNewGameAction());
  return store;
}
