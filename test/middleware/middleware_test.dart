import 'dart:async';

import 'package:test/test.dart';
import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';
import 'mock_firestore_db.dart';

Future<void> handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

void main() {
  test('test create and set up room', () async {
    FirestoreDb db = new MockFirestoreDb();
    Store<GameModel> store = createStore(db);

    await handle(store, new CreateRoomAction());
    expect(store.state.room.code.length, 4);

    await handle(store, new LoadGameAction());
    expect(store.state.subscriptions.subs, isNotEmpty);
    expect(store.state.room.appVersion, isNotNull);
    expect(store.state.room.numPlayers, minPlayers);

    for (int i = 0; i < store.state.room.numPlayers; i++) {
      await db.upsertPlayer(new Player(
          installId: new Uuid().v4(),
          name: new Uuid().v4(),
          initialBalance: 8), store.state.room.id);
    }

    await handle(store, new SetUpNewGameAction());
    expect(store.state.players.length, store.state.room.numPlayers);
    for (Player player in store.state.players) {
      expect(player.role, isNotNull);
    }
    expect(store.state.heists.length, 1);
  });
}
