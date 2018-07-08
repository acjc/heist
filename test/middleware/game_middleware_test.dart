import 'package:test/test.dart';
import 'package:heist/main.dart';
import 'package:redux/redux.dart';

import '../mock_firestore_db.dart';
import '../test_utils.dart';

void main() {
  test('join existing game', () async {
    String code = 'ABCD';
    String heistId = uuid();
    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(), code: code, numPlayers: 2, roles: new Set.of(['KINGPIN', 'LEAD_AGENT'])),
        players: [
          new Player(id: uuid(), installId: installId(), name: '_name', role: 'KINGPIN'),
          new Player(id: uuid(), installId: uuid(), name: '_player2', role: 'LEAD_AGENT'),
        ],
        heists: [
          new Heist(id: heistId, price: 12, numPlayers: 2, order: 1, startedAt: now()),
        ],
        rounds: {
          heistId: [new Round(id: uuid(), order: 1, heist: heistId, startedAt: now())]
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
    expect(getSelf(store.state), isNotNull);
    expect(store.state.heists.length, 1);
    expect(hasRounds(store.state), true);
  });
}
