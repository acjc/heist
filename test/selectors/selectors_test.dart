import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../mock_firestore_db.dart';
import '../test_utils.dart';

void main() {
  test('calculate balance', () async {
    String myId = uuid();
    String otherId = uuid();
    String heistId1 = uuid();
    String heistId2 = uuid();
    FirestoreDb db = new MockFirestoreDb(
        room: new Room(
            id: uuid(), code: 'ABCD', numPlayers: 2, roles: new Set.of(['KINGPIN', 'LEAD_AGENT'])),
        players: [
          new Player(
              id: myId, installId: installId(), name: '_name', role: 'KINGPIN'),
          new Player(
              id: otherId, installId: uuid(), name: '_other', role: 'LEAD_AGENT'),
        ],
        heists: [
          new Heist(
              id: heistId1,
              price: 12,
              numPlayers: 2,
              order: 1,
              decisions: {myId: 'SUCCEED', otherId: 'SUCCEED'},
              startedAt: now()),
          new Heist(id: heistId2, price: 12, numPlayers: 2, order: 2, startedAt: now())
        ],
        rounds: {
          heistId1: [
            new Round(
                id: uuid(),
                order: 1,
                heist: heistId1,
                bids: {},
                gifts: {uuid(): new Gift(amount: 10, recipient: myId)},
                startedAt: now()),
            new Round(
                id: uuid(),
                order: 2,
                heist: heistId1,
                bids: {myId: new Bid(13)},
                gifts: {},
                startedAt: now())
          ],
          heistId2: [
            new Round(
                id: uuid(),
                order: 1,
                heist: heistId2,
                gifts: {myId: new Gift(amount: 3, recipient: uuid())},
                bids: {myId: new Bid(11)},
                startedAt: now())
          ]
        });
    Store<GameModel> store = createStore(db);

    await handle(store, new LoadGameAction());

    expect(currentBalance(store.state), 2);
  });
}
