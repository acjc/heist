import 'dart:math';

import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
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
    String brendaId = uuid();
    String bertieId = uuid();
    String scaryId = uuid();
    String hauntId1 = '#haunt1';
    String hauntId2 = '#haunt2';

    Player kingpin =
        new Player(id: brendaId, installId: uuid(), name: '_other1', role: Roles.brenda.roleId);
    Player leadAgent =
        new Player(id: bertieId, installId: uuid(), name: '_other2', role: Roles.bertie.roleId);
    Player thief =
        new Player(id: scaryId, installId: uuid(), name: '_other3', role: Roles.scaryGhost1.roleId);

    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(),
            code: 'ABCD',
            numPlayers: 2,
            roles: new Set.of([
              Roles.brenda.roleId,
              Roles.bertie.roleId,
              Roles.friendlyGhost1.roleId,
              Roles.scaryGhost1.roleId
            ])),
        players: [
          new Player(
              id: myId,
              installId: DebugInstallId,
              name: '_name',
              role: Roles.friendlyGhost1.roleId),
          kingpin,
          leadAgent,
          thief,
        ],
        haunts: [
          new Haunt(
              id: hauntId1,
              price: 12,
              numPlayers: 4,
              maximumBid: 20,
              order: 1,
              decisions: {
                myId: Steal,
                brendaId: Scare,
                bertieId: Tickle,
                scaryId: Steal,
              },
              startedAt: now()),
          new Haunt(
              id: hauntId2, price: 12, numPlayers: 4, maximumBid: 20, order: 2, startedAt: now())
        ],
        rounds: {
          hauntId1: [
            new Round(
                id: uuid(),
                order: 1,
                haunt: hauntId1,
                team: new Set(),
                bids: {},
                gifts: {brendaId: new Gift(amount: 7, recipient: myId)},
                startedAt: now()),
            new Round(
                id: uuid(),
                order: 2,
                haunt: hauntId1,
                team: new Set(),
                bids: {
                  myId: new Bid(10),
                  brendaId: new Bid(1),
                  bertieId: new Bid(1),
                  scaryId: new Bid(1)
                },
                gifts: {},
                startedAt: now())
          ],
          hauntId2: [
            new Round(
                id: uuid(),
                order: 1,
                haunt: hauntId2,
                team: new Set(),
                gifts: {myId: new Gift(amount: 3, recipient: brendaId)},
                bids: {myId: new Bid(2)},
                startedAt: now())
          ]
        });
    Store<GameModel> store = createStore(db);

    await handle(store, new LoadGameAction());

    // 8 + 7 (gift) - 10 (bid) + 2 (half of 13 split 3 ways) - 3 (gift) - 2 (proposed bid)
    expect(currentBalance(store.state), 2);

    // 8 - 7 (gift) - bid (1) + 6 (half of 13) + 3 (gift)
    expect(calculateBalanceFromStore(store, kingpin), 9);

    // 8 - 1 (bid) + 2 (half of 13 split 3 ways)
    expect(calculateBalanceFromStore(store, leadAgent), 9);

    // 8 - 1 (bid) + 3 (half of 13 split 3 ways)
    expect(calculateBalanceFromStore(store, thief), 10);
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
