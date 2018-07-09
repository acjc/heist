part of heist;

class SubmitBidAction extends MiddlewareAction {
  final String playerId;
  final int amount;

  SubmitBidAction(this.playerId, this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(
        Request.Bidding,
        store,
        (store) =>
            store.state.db.submitBid(currentRound(store.state).id, playerId, new Bid(amount)));
  }
}

class CancelBidAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(Request.Bidding, store,
        (store) => store.state.db.cancelBid(currentRound(store.state).id, getSelf(store.state).id));
  }
}
