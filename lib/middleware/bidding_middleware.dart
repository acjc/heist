part of heist;

class SubmitBidAction extends MiddlewareAction {
  final int amount;

  SubmitBidAction(this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.Bidding));
    print('Submit bid');
    store.dispatch(new RequestCompleteAction(Request.Bidding));
  }
}