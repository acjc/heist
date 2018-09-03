import 'package:redux/redux.dart';

import 'reducers.dart';

final bidAmountReducer = combineReducers<int>([
  new TypedReducer<int, IncrementBidAmountAction>(reduce),
  new TypedReducer<int, DecrementBidAmountAction>(reduce),
]);

class IncrementBidAmountAction extends Action<int> {
  final int maximumBid;

  IncrementBidAmountAction(this.maximumBid);

  @override
  int reduce(int bidAmount, action) {
    return bidAmount < maximumBid ? bidAmount + 1 : bidAmount;
  }
}

class DecrementBidAmountAction extends Action<int> {
  @override
  int reduce(int bidAmount, action) {
    return bidAmount > 0 ? bidAmount - 1 : bidAmount;
  }
}
