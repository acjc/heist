import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/player_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../mock_firestore_db.dart';
import '../test_utils.dart';

void main() {
  test('test create and set up room', () async {
    FirestoreDb db = new MockFirestoreDb.empty();
    Store<GameModel> store = createStore(db, minPlayers);
    store.dispatch(new SetPlayerNameAction('_name'));

    await handle(store, new CreateRoomAction());
    expect(store.state.room.code.length, 4);
    expect(store.state.room.appVersion, isNotNull);
    expect(store.state.room.numPlayers, minPlayers);
    expect(
        store.state.room.roles,
        new Set.of([
          ACCOUNTANT.roleId,
          KINGPIN.roleId,
          THIEF_1.roleId,
          LEAD_AGENT.roleId,
          AGENT_1.roleId
        ]));

    // Call loadGame() manually to avoid some async calls that we call manually later in the test
    await new LoadGameAction().loadGame(store);
    expect(store.state.subscriptions.subs, isNotEmpty);

    await handle(store, new JoinGameAction());
    expect(getSelf(store.state), isNotNull);

    await addOtherPlayers(store);

    await handle(store, new SetUpNewGameAction());
    expect(store.state.players.length, store.state.room.numPlayers);
    expect(waitingForPlayers(store.state), false);
    for (Player player in store.state.players) {
      expect(player.role, isNotNull);
    }
    expect(store.state.heists.length, 1);
  });
}
