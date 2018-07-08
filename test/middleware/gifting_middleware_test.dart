import 'package:heist/main.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test send gift', () async {
    Store<GameModel> store = await initGame();

    String recipient = getOtherPlayers(store.state).first.id;

    await handle(store, new SendGiftAction(recipient, 10));
    Gift gift = myCurrentGift(store.state);
    expect(gift.recipient, recipient);
    expect(gift.amount, 10);
  });
}
