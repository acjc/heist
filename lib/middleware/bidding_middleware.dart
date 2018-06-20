part of heist;

class SubmitBidAction extends MiddlewareAction {
  final int amount;

  SubmitBidAction(this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.Bidding));
    await store.state.db
        .submitBid(currentRound(store.state).id, getSelf(store.state).id, new Bid(amount));
    store.dispatch(new RequestCompleteAction(Request.Bidding));
  }
}

class CancelBidAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.Bidding));
    await store.state.db.cancelBid(currentRound(store.state).id, getSelf(store.state).id);
    store.dispatch(new RequestCompleteAction(Request.Bidding));
  }
}
