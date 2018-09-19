import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/middleware/haunt_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test make decision', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, MakeDecisionAction(Steal));
    expect(currentHaunt(store.state).decisions[myId], Steal);
  });

  test('test complete haunt', () async {
    Store<GameModel> store = await initGame();

    expect(getHaunts(store.state).length, 5);
    await handle(store, CompleteHauntAction());

    Haunt previousHaunt = getHaunts(store.state).singleWhere((h) => h.order == 1);
    expect(previousHaunt.completedAt, isNotNull);
  });
}
