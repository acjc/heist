import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/round_end_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test complete round', () async {
    Store<GameModel> store = await initGame();

    await handle(store, new CompleteRoundAction());
    Round newRound = currentRound(store.state);
    expect(getRounds(store.state)[newRound.heist].singleWhere((r) => r.order == 1).complete, true);
    expect(newRound.complete, false);
    expect(newRound.order, 2);
  });

  test('test next leader', () async {
    Store<GameModel> store = await initGame();
    List<Player> players = getPlayers(store.state);

    expect(currentRound(store.state).leader, players.singleWhere((p) => p.order == 1).id);

    expect(nextRoundLeader(players, 1, false), players.singleWhere((p) => p.order == 2).id);
    expect(nextRoundLeader(players, players.length, false),
        players.singleWhere((p) => p.order == 1).id);
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
