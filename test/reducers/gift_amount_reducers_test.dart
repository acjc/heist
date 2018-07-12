import 'package:test/test.dart';
import 'package:heist/main.dart';

void main() {
  test('increment giftAmount', () {
    int giftAmount = reduce(4, new IncrementGiftAmountAction(5));
    expect(giftAmount, 5);
    giftAmount = reduce(giftAmount, new IncrementGiftAmountAction(5));
    expect(giftAmount, 5);
  });

  test('decrement giftAmount', () {
    int giftAmount = reduce(1, new DecrementGiftAmountAction());
    expect(giftAmount, 0);
    giftAmount = reduce(giftAmount, new DecrementGiftAmountAction());
    expect(giftAmount, 0);
  });
}
