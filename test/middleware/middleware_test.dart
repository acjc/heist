import 'dart:async';

import 'package:test/test.dart';
import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'mock_firestore_db.dart';

Future<void> handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

void main() {
  test('test create room', () async {
    FirestoreDb db = new MockFirestoreDb();
    Store<GameModel> store = createStore(db);

    await handle(store, new CreateRoomAction());
    await handle(store, new LoadGameAction());

    expect(store.state.room.code.length, 4);
    expect(store.state.room.appVersion, isNotNull);
    expect(store.state.room.numPlayers, minPlayers);
    expect(store.state.subscriptions.subs, isNotEmpty);
  });
}
