part of heist;

final giftAmountReducer = combineReducers<int>([
  new TypedReducer<int, IncrementGiftAmountAction>(reduce),
  new TypedReducer<int, DecrementGiftAmountAction>(reduce),
]);

class IncrementGiftAmountAction extends Action<int> {
  final int balance;

  IncrementGiftAmountAction(this.balance);

  @override
  int reduce(int giftAmount, action) {
    return giftAmount < balance ? giftAmount + 1 : giftAmount;
  }
}

class DecrementGiftAmountAction extends Action<int> {
  @override
  int reduce(int giftAmount, action) {
    return giftAmount > 0 ? giftAmount - 1 : giftAmount;
  }
}
