import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test submit and cancel bid', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, SubmitBidAction(bidder: myId, recipient: myId, amount: 10));
    expect(myCurrentBid(store.state).amount, 10);
    await handle(store, CancelBidAction());
    expect(myCurrentBid(store.state), isNull);
  });
}
