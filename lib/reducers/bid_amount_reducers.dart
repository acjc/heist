import 'dart:math';

import 'package:redux/redux.dart';

import 'reducers.dart';

final bidAmountReducer = combineReducers<int>([
  new TypedReducer<int, IncrementBidAmountAction>(reduce),
  new TypedReducer<int, DecrementBidAmountAction>(reduce),
]);

class IncrementBidAmountAction extends Action<int> {
  final int balance;
  final int maximumBid;

  IncrementBidAmountAction(this.balance, this.maximumBid);

  @override
  int reduce(int bidAmount, action) {
    return bidAmount < min(balance, maximumBid) ? bidAmount + 1 : bidAmount;
  }
}

class DecrementBidAmountAction extends Action<int> {
  @override
  int reduce(int bidAmount, action) {
    return bidAmount > 0 ? bidAmount - 1 : bidAmount;
  }
}
