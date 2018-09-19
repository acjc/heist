import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/form_reducers.dart';
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
    store.dispatch(new SavePlayerNameAction('_name'));

    await handle(store, new CreateRoomAction(null, () => true));
    expect(store.state.room.code.length, 4);
    expect(store.state.room.appVersion, isNotNull);
    expect(store.state.room.numPlayers, minPlayers);
    expect(
        store.state.room.roles,
        new Set.of([
          Roles.accountant.roleId,
          Roles.brenda.roleId,
          Roles.scaryGhost1.roleId,
          Roles.bertie.roleId,
          Roles.friendlyGhost1.roleId
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
    expect(store.state.haunts.length, 1);
  });

  test('add visible to accountant player', () async {
    Store<GameModel> store = await initGame();
    expect(store.state.room.visibleToAccountant, null);

    await handle(store, new AddVisibleToAccountantAction("player1"));
    expect(store.state.room.visibleToAccountant.length, 1);
    expect(store.state.room.visibleToAccountant.contains("player1"), true);

    await handle(store, new AddVisibleToAccountantAction("player2"));
    expect(store.state.room.visibleToAccountant.length, 2);
    expect(store.state.room.visibleToAccountant.containsAll(["player1", "player2"]), true);
  });
}
