import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/exclusion_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, PickPlayerMiddlewareAction(myId));
    Player onlyExclusion = currentExclusions(store.state).single;
    expect(onlyExclusion.id, myId);
    expect(onlyExclusion.name, '_name');

    await handle(store, RemovePlayerMiddlewareAction(myId));
    expect(currentExclusions(store.state), isEmpty);
  });
}
