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

    expect(currentRound(store.state).complete, false);
    await handle(store, CompleteRoundAction(currentRound(store.state).id));
    Round newRound = currentRound(store.state);
    expect(getRounds(store.state)[newRound.haunt].singleWhere((r) => r.order == 1).complete, true);
    expect(newRound.complete, false);
    expect(newRound.order, 2);
  });
}
