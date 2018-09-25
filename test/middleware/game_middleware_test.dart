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
    FirestoreDb db = MockFirestoreDb(
        room: Room(
            id: uuid(),
            code: code,
            numPlayers: 2,
            roles: Set.of([Roles.brenda.roleId, Roles.bertie.roleId])),
        players: [
          Player(id: uuid(), installId: DebugInstallId, name: '_name', role: Roles.brenda.roleId),
          Player(id: uuid(), installId: uuid(), name: '_player2', role: Roles.bertie.roleId),
        ],
        haunts: [
          Haunt(id: hauntId, price: 12, numPlayers: 2, maximumBid: 5, order: 1, startedAt: now()),
        ],
        rounds: {
          hauntId: [Round(id: uuid(), order: 1, haunt: hauntId, team: Set(), startedAt: now())]
        });
    Store<GameModel> store = createStore(db);

    store.dispatch(SetRoomCodeAction(code));
    expect(getRoom(store.state).code, code);

    await LoadGameAction().loadGame(store);

    Room room = getRoom(store.state);
    expect(store.state.subscriptions.subs, isNotEmpty);
    expect(room.numPlayers, 2);
    expect(room.roles, Set.of(['BRENDA', 'BERTIE']));
    List<Player> players = getPlayers(store.state);
    expect(players.length, room.numPlayers);
    for (Player player in players) {
      expect(player.role, isNotNull);
      expect(true, room.roles.contains(player.role));
    }
    expect(getSelf(store.state), isNotNull);
    expect(store.state.haunts.length, 1);
  });
}
