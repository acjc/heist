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

class CompleteRoundAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.completeRound(currentRound(store.state).id);
  }
}

class CreateNewRoundAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(Request.CreatingNewRound, store, (store) {
      String currentHeistId = currentHeist(store.state).id;
      int newOrder = currentRound(store.state).order + 1;
      assert(newOrder > 0 && newOrder <= 5);
      String newLeader = nextRoundLeader(
          getPlayers(store.state), roundLeader(store.state).order, isAuction(store.state));

      return createNewRound(store, currentHeistId, newOrder, newLeader);
    });
  }
}

String nextRoundLeader(List<Player> players, int currentOrder, bool wasAuction) {
  int newOrder = wasAuction ? currentOrder : currentOrder + 1;
  if (newOrder > players.length) {
    newOrder = 1;
  }
  return players.singleWhere((p) => p.order == newOrder).id;
}

Future<void> createNewRound(
    Store<GameModel> store, String heistId, int order, String leader) async {
  FirestoreDb db = store.state.db;
  String roomId = getRoom(store.state).id;
  assert(!(await db.roundExists(roomId, heistId, order)));

  Round newRound = new Round(leader: leader, order: order, heist: heistId, startedAt: now());
  return db.upsertRound(newRound, roomId);
}
