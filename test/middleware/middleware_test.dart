import 'dart:async';

import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'mock_firestore_db.dart';

Future<void> _handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

Future<void> _addOtherPlayers(Store<GameModel> store) async {
  for (int i = 0; i < store.state.room.numPlayers - 1; i++) {
    await store.state.db.upsertPlayer(
        new Player(installId: _uuid(), name: _uuid(), initialBalance: 8), store.state.room.id);
  }
}

String _uuid() {
  return new Uuid().v4();
}

void main() {
  test('test create and set up room', () async {
    FirestoreDb db = new MockFirestoreDb.empty();
    Store<GameModel> store = createStore(db);
    store.dispatch(new SetPlayerNameAction('_name'));

    await _handle(store, new CreateRoomAction());
    expect(store.state.room.code.length, 4);
    expect(store.state.room.appVersion, isNotNull);
    expect(store.state.room.numPlayers, minPlayers);
    expect(
        store.state.room.roles,
        new Set.of(['ACCOUNTANT', 'KINGPIN', 'THIEF_1', 'LEAD_AGENT', 'AGENT_1']));


    // Call loadGame() manually to avoid some async calls that we call manually later in the test
    await new LoadGameAction().loadGame(store);
    expect(store.state.subscriptions.subs, isNotEmpty);

    await _handle(store, new JoinGameAction());
    expect(store.state.me(), isNotNull);

    await _addOtherPlayers(store);

    await _handle(store, new SetUpNewGameAction());
    expect(store.state.players.length, store.state.room.numPlayers);
    for (Player player in store.state.players) {
      expect(player.role, isNotNull);
    }
    expect(store.state.heists.length, 1);
  });

  test('join existing game', () async {
    String code = 'ABCD';
    String heistId = _uuid();
    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: _uuid(),
            code: code,
            numPlayers: 2,
            roles: new Set.of(['KINGPIN', 'LEAD_AGENT'])),
        players: [
          new Player(id: _uuid(), installId: installId(), name: '_name', role: 'KINGPIN'),
          new Player(id: _uuid(), installId: _uuid(), name: '_player2', role: 'LEAD_AGENT'),
        ],
        heists: [
          new Heist(id: heistId, price: 12, numPlayers: 2, order: 1, startedAt: now())
        ],
        rounds: {
          heistId: [new Round(id: _uuid(), order: 1, startedAt: now())]
        });
    Store<GameModel> store = createStore(db);

    store.dispatch(new SetRoomCodeAction(code));
    expect(store.state.room.code, code);

    await new LoadGameAction().loadGame(store);

    expect(store.state.subscriptions.subs, isNotEmpty);
    expect(store.state.room.numPlayers, 2);
    expect(store.state.room.roles, new Set.of(['KINGPIN', 'LEAD_AGENT']));
    expect(store.state.players.length, store.state.room.numPlayers);
    for (Player player in store.state.players) {
      expect(player.role, isNotNull);
      expect(true, store.state.room.roles.contains(player.role));
    }
    expect(store.state.me(), isNotNull);
    expect(store.state.heists.length, 1);
    expect(store.state.hasRounds(), true);
  });
}
