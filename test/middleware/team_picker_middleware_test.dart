import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, new PickPlayerMiddlewareAction(myId));
    expect(teamIds(store.state).single, myId);
    expect(teamNames(store.state).single, '_name');
    await handle(store, new RemovePlayerMiddlewareAction(myId));
    expect(teamIds(store.state), isEmpty);
    expect(teamNames(store.state), isEmpty);
  });
}
