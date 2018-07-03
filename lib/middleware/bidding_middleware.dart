part of heist;

class SubmitBidAction extends MiddlewareAction {
  final String playerId;
  final int amount;

  SubmitBidAction(this.playerId, this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.Bidding));
    await store.state.db
        .submitBid(currentRound(store.state).id, playerId, new Bid(amount));
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

class CompleteRoundAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.completeRound(currentRound(store.state).id);
  }
}
