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
  String myId = uuid();
  String brendaId = uuid();
  String bertieId = uuid();
  String scaryId = uuid();
  String hauntId1 = '#haunt1';
  String hauntId2 = '#haunt2';

  Player kingpin = Player(
    id: brendaId,
    installId: uuid(),
    name: '_other1',
    role: Roles.brenda.roleId,
    order: 1,
  );
  Player leadAgent = Player(
    id: bertieId,
    installId: uuid(),
    name: '_other2',
    role: Roles.bertie.roleId,
    order: 2,
  );
  Player thief = Player(
    id: scaryId,
    installId: uuid(),
    name: '_other3',
    role: Roles.scaryGhost1.roleId,
    order: 3,
  );

  Store<GameModel> store;

  setUp(() async {
    FirestoreDb db = MockFirestoreDb(
        room: Room(
            id: uuid(),
            code: 'ABCD',
            numPlayers: 2,
            roles: Set.of([
              Roles.brenda.roleId,
              Roles.bertie.roleId,
              Roles.friendlyGhost1.roleId,
              Roles.scaryGhost1.roleId
            ])),
        players: [
          Player(
              id: myId,
              installId: DebugInstallId,
              name: '_name',
              role: Roles.friendlyGhost1.roleId,
              order: 4),
          kingpin,
          leadAgent,
          thief,
        ],
        haunts: [
          Haunt(
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
            startedAt: now(),
            completedAt: now(),
          ),
          Haunt(id: hauntId2, price: 12, numPlayers: 4, maximumBid: 20, order: 2, startedAt: now())
        ],
        rounds: {
          hauntId1: [
            Round(
              id: uuid(),
              order: 1,
              haunt: hauntId1,
              team: Set(),
              bids: {},
              gifts: {brendaId: Gift(amount: 7, recipient: myId)},
              startedAt: now(),
              completedAt: now(),
            ),
            Round(
              id: uuid(),
              order: 2,
              haunt: hauntId1,
              team: Set(),
              bids: {myId: Bid(10), brendaId: Bid(1), bertieId: Bid(1), scaryId: Bid(1)},
              gifts: {},
              startedAt: now(),
              completedAt: now(),
            )
          ],
          hauntId2: [
            Round(
              id: uuid(),
              order: 1,
              haunt: hauntId2,
              team: Set(),
              gifts: {myId: Gift(amount: 3, recipient: brendaId)},
              bids: {myId: Bid(2)},
              startedAt: now(),
            )
          ]
        });
    store = createStore(db);
    await handle(store, LoadGameAction());
  });

  test('rounds so far', () {
    Round lastRoundInFirstHaunt = getRounds(store.state)[hauntId1][0];
    expect(playerLedRoundsSoFar(store.state), 2);
    expect(currentLeader(store.state).id, scaryId);
    expect(leaderForRound(store.state, lastRoundInFirstHaunt).id, bertieId);
  });

  test('calculate balance', () {
    // 8 + 7 (gift) - 10 (bid) + 2 (half of 13 split 3 ways) - 3 (gift) - 2 (proposed bid)
    expect(currentBalance(store.state), 2);

    // 8 - 7 (gift) - bid (1) + 6 (half of 13) + 3 (gift)
    expect(calculateBalanceFromState(store.state, kingpin), 9);

    // 8 - 1 (bid) + 2 (half of 13 split 3 ways)
    expect(calculateBalanceFromState(store.state, leadAgent), 9);

    // 8 - 1 (bid) + 3 (half of 13 split 3 ways)
    expect(calculateBalanceFromState(store.state, thief), 10);
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
  Random random = Random();
  List<int> split = randomlySplit(random, n, ways);
  expect(split.reduce((a, b) => a + b), n);
  expect(split.reduce(min), (n / ways).floor());
  expect(split.reduce(max), (n / ways).ceil());
}
