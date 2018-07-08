part of heist;

final bidAmountReducer = combineReducers<int>([
  new TypedReducer<int, IncrementBidAmountAction>(reduce),
  new TypedReducer<int, DecrementBidAmountAction>(reduce),
]);

class IncrementBidAmountAction extends Action<int> {
  final int balance;

  IncrementBidAmountAction(this.balance);

  @override
  int reduce(int bidAmount, action) {
    return bidAmount < balance ? bidAmount + 1 : bidAmount;
  }
}

class DecrementBidAmountAction extends Action<int> {
  @override
  int reduce(int bidAmount, action) {
    return bidAmount > 0 ? bidAmount - 1 : bidAmount;
  }
}
