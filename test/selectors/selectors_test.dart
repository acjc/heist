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
    String leadAgentId = uuid();
    String thiefId = uuid();
    String heistId1 = '#heist1';
    String heistId2 = '#heist2';

    Player kingpin =
        new Player(id: kingpinId, installId: uuid(), name: '_other1', role: KINGPIN.roleId);
    Player leadAgent =
        new Player(id: leadAgentId, installId: uuid(), name: '_other2', role: LEAD_AGENT.roleId);
    Player thief =
        new Player(id: thiefId, installId: uuid(), name: '_other3', role: THIEF_1.roleId);

    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(),
            code: 'ABCD',
            numPlayers: 2,
            roles: new Set.of([KINGPIN.roleId, LEAD_AGENT.roleId, AGENT_1.roleId, THIEF_1.roleId])),
        players: [
          new Player(id: myId, installId: DebugInstallId, name: '_name', role: AGENT_1.roleId),
          kingpin,
          leadAgent,
          thief,
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
                leadAgentId: Fail,
                thiefId: Steal,
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
                gifts: {kingpinId: new Gift(amount: 7, recipient: myId)},
                startedAt: now()),
            new Round(
                id: uuid(),
                order: 2,
                heist: heistId1,
                team: new Set(),
                bids: {
                  myId: new Bid(10),
                  kingpinId: new Bid(1),
                  leadAgentId: new Bid(1),
                  thiefId: new Bid(1)
                },
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
                bids: {myId: new Bid(2)},
                startedAt: now())
          ]
        });
    Store<GameModel> store = createStore(db);

    await handle(store, new LoadGameAction());

    // 8 + 7 (gift) - 10 (bid) + 2 (half of 13 split 3 ways) - 3 (gift) - 2 (proposed bid)
    expect(currentBalance(store.state), 2);

    // 8 - 7 (gift) - bid (1) + 7 (half of 13) + 3 (gift)
    expect(calculateBalanceFromStore(store, kingpin), 10);

    // 8 - 1 (bid) + 2 (half of 13 split 3 ways)
    expect(calculateBalanceFromStore(store, leadAgent), 9);

    // 8 - 1 (bid) + 2 (half of 13 split 3 ways)
    expect(calculateBalanceFromStore(store, thief), 9);
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
