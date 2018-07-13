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
}
