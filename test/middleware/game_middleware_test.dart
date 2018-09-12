import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../mock_firestore_db.dart';
import '../test_utils.dart';

void main() {
  test('join existing game', () async {
    String code = 'ABCD';
    String hauntId = uuid();
    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(),
            code: code,
            numPlayers: 2,
            roles: new Set.of([Roles.brenda.roleId, Roles.bertie.roleId])),
        players: [
          new Player(
              id: uuid(), installId: DebugInstallId, name: '_name', role: Roles.brenda.roleId),
          new Player(id: uuid(), installId: uuid(), name: '_player2', role: Roles.bertie.roleId),
        ],
        haunts: [
          new Haunt(
              id: hauntId, price: 12, numPlayers: 2, maximumBid: 5, order: 1, startedAt: now()),
        ],
        rounds: {
          hauntId: [
            new Round(id: uuid(), order: 1, haunt: hauntId, team: new Set(), startedAt: now())
          ]
        });
    Store<GameModel> store = createStore(db);

    store.dispatch(new SetRoomCodeAction(code));
    expect(store.state.room.code, code);

    await new LoadGameAction().loadGame(store);

    expect(store.state.subscriptions.subs, isNotEmpty);
    expect(store.state.room.numPlayers, 2);
    expect(store.state.room.roles, new Set.of(['BRENDA', 'BERTIE']));
    expect(store.state.players.length, store.state.room.numPlayers);
    for (Player player in store.state.players) {
      expect(player.role, isNotNull);
      expect(true, store.state.room.roles.contains(player.role));
    }
    expect(getSelf(store.state), isNotNull);
    expect(store.state.haunts.length, 1);
    expect(hasRounds(store.state), true);
  });
}
