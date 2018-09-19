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
    FirestoreDb db = MockFirestoreDb.empty();
    Store<GameModel> store = createStore(db, minPlayers);
    store.dispatch(SavePlayerNameAction('_name'));

    await handle(store, CreateRoomAction(null, () => true));
    Room room = getRoom(store.state);
    expect(room.code.length, 4);
    expect(room.appVersion, isNotNull);
    expect(room.numPlayers, minPlayers);
    expect(
        room.roles,
        Set.of([
          Roles.accountant.roleId,
          Roles.brenda.roleId,
          Roles.scaryGhost1.roleId,
          Roles.bertie.roleId,
          Roles.friendlyGhost1.roleId
        ]));

    // Call loadGame() manually to avoid some async calls that we call manually later in the test
    await LoadGameAction().loadGame(store);
    expect(store.state.subscriptions.subs, isNotEmpty);

    await handle(store, JoinGameAction());
    expect(getSelf(store.state), isNotNull);

    await addOtherPlayers(store);

    await handle(store, SetUpNewGameAction());
    List<Player> players = getPlayers(store.state);
    expect(players.length, room.numPlayers);
    expect(waitingForPlayers(store.state), false);
    for (Player player in players) {
      expect(player.role, isNotNull);
    }
    expect(getHaunts(store.state).length, 5);
    expect(getRounds(store.state).length, 5);
    expect(getRounds(store.state).values.expand((rs) => rs).length, 25);
  });

  test('add visible to accountant player', () async {
    Store<GameModel> store = await initGame();
    expect(getRoom(store.state).visibleToAccountant, null);

    await handle(store, AddVisibleToAccountantAction('player1'));
    expect(getRoom(store.state).visibleToAccountant.length, 1);
    expect(getRoom(store.state).visibleToAccountant.contains('player1'), true);

    await handle(store, AddVisibleToAccountantAction('player2'));
    expect(getRoom(store.state).visibleToAccountant.length, 2);
    expect(getRoom(store.state).visibleToAccountant.containsAll(['player1', 'player2']), true);
  });
}
