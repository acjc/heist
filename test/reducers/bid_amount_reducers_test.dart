import 'package:test/test.dart';
import 'package:heist/main.dart';

void main() {
  test('increment bidAmount', () {
    int bidAmount = reduce(4, new IncrementBidAmountAction(5));
    expect(bidAmount, 5);
    bidAmount = reduce(bidAmount, new IncrementBidAmountAction(5));
    expect(bidAmount, 5);
  });

  test('decrement bidAmount', () {
    int bidAmount = reduce(1, new DecrementBidAmountAction());
    expect(bidAmount, 0);
    bidAmount = reduce(bidAmount, new DecrementBidAmountAction());
    expect(bidAmount, 0);
  });
}
