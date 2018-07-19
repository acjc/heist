import 'dart:math';

import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/game_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../mock_firestore_db.dart';
import '../test_utils.dart';

void main() {
  test('calculate balance', () async {
    String myId = uuid();
    String kingpinId = uuid();
    String otherPlayer2 = uuid();
    String otherPlayer3 = uuid();
    String heistId1 = '#heist1';
    String heistId2 = '#heist2';

    Player kingpin =
        new Player(id: kingpinId, installId: uuid(), name: '_other1', role: KINGPIN.roleId);

    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(),
            code: 'ABCD',
            numPlayers: 2,
            roles: new Set.of([KINGPIN.roleId, LEAD_AGENT.roleId, AGENT_1.roleId, THIEF_1.roleId])),
        players: [
          new Player(id: myId, installId: DebugInstallId, name: '_name', role: AGENT_1.roleId),
          kingpin,
          new Player(id: otherPlayer2, installId: uuid(), name: '_other2', role: LEAD_AGENT.roleId),
          new Player(id: otherPlayer3, installId: uuid(), name: '_other3', role: THIEF_1.roleId),
        ],
        heists: [
          new Heist(
              id: heistId1,
              price: 12,
              numPlayers: 4,
              maximumBid: 20,
              order: 1,
              decisions: {
                myId: Steal,
                kingpinId: Succeed,
                otherPlayer2: Steal,
                otherPlayer3: Steal
              },
              startedAt: now()),
          new Heist(
              id: heistId2, price: 12, numPlayers: 4, maximumBid: 20, order: 2, startedAt: now())
        ],
        rounds: {
          heistId1: [
            new Round(
                id: uuid(),
                order: 1,
                heist: heistId1,
                team: new Set(),
                bids: {},
                gifts: {kingpinId: new Gift(amount: 10, recipient: myId)},
                startedAt: now()),
            new Round(
                id: uuid(),
                order: 2,
                heist: heistId1,
                team: new Set(),
                bids: {myId: new Bid(12), kingpinId: new Bid(1)},
                gifts: {},
                startedAt: now())
          ],
          heistId2: [
            new Round(
                id: uuid(),
                order: 1,
                heist: heistId2,
                team: new Set(),
                gifts: {myId: new Gift(amount: 3, recipient: kingpinId)},
                bids: {myId: new Bid(11)},
                startedAt: now())
          ]
        });
    Store<GameModel> store = createStore(db);

    await handle(store, new LoadGameAction());

    expect(currentBalance(store.state), 5);
    expect(calculateBalanceFromStore(store, kingpin), 7);
  });

  test('randomly split', () {
    checkSplit(10, 3);
    checkSplit(33, 7);
    checkSplit(12, 4);
    checkSplit(1, 2);
    checkSplit(0, 1);
  });
}

void checkSplit(int n, int ways) {
  Random random = new Random();
  List<int> split = randomlySplit(random, n, ways);
  expect(split.reduce((a, b) => a + b), n);
  expect(split.reduce(min), (n / ways).floor());
  expect(split.reduce(max), (n / ways).ceil());
}
