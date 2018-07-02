import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test make decision', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, new MakeDecisionAction('STEAL'));
    expect(currentHeist(store.state).decisions[myId], 'STEAL');
  });
}
