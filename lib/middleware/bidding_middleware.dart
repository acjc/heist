part of heist;

class SubmitBidAction extends MiddlewareAction {
  final int amount;

  SubmitBidAction(this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String myPlayerId = getSelf(store.state).id;
    store.dispatch(new StartRequestAction(Request.Bidding));
    await store.state.db.submitBid(currentRound(store.state).id, myPlayerId, new Bid(amount));
    store.dispatch(new RequestCompleteAction(Request.Bidding));
  }
}
