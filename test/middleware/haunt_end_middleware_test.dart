import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/haunt_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test complete haunt', () async {
    Store<GameModel> store = await initGame();

    expect(getHaunts(store.state).length, 1);
    await handle(store, new CompleteHauntAction());
    expect(getHaunts(store.state).length, 2);
    expect(getRounds(store.state).values.length, 2);

    Haunt previousHaunt = getHaunts(store.state).singleWhere((h) => h.order == 1);
    expect(previousHaunt.completedAt, isNotNull);
  });
}
