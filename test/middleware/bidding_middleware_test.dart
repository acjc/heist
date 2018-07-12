import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test submit and cancel bid', () async {
    Store<GameModel> store = await initGame();

    await handle(store, new SubmitBidAction(getSelf(store.state).id, 10));
    expect(myCurrentBid(store.state).amount, 10);
    await handle(store, new CancelBidAction());
    expect(myCurrentBid(store.state), isNull);
  });

  test('test complete round', () async {
    Store<GameModel> store = await initGame();

    await handle(store, new CompleteRoundAction());
    expect(currentRound(store.state).completedAt, isNotNull);
  });

  test('test next leader', () async {
    Store<GameModel> store = await initGame();
    List<Player> players = getPlayers(store.state);

    expect(currentRound(store.state).leader, players.singleWhere((p) => p.order == 1).id);

    expect(nextRoundLeader(players, 1, false), players.singleWhere((p) => p.order == 2).id);
    expect(nextRoundLeader(players, players.length, false), players.singleWhere((p) => p.order == 1).id);
    expect(nextRoundLeader(players, 3, true), players.singleWhere((p) => p.order == 3).id);
  });

  test('test create new round', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await createNewRound(store, currentHeist(store.state).id, 2, myId);

    Round round = currentRound(store.state);
    expect(round.order, 2);
    expect(round.leader, myId);
    expect(getRounds(store.state)[round.heist].length, 2);
  });
}
