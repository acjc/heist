part of heist;

class CompleteRoundAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(Request.CompletingRound, store, (store) async {
      Round round = currentRound(store.state);

      if (!heistIsActive(store.state)) {
        String currentHeistId = currentHeist(store.state).id;
        int newOrder = round.order + 1;
        assert(newOrder > 0 && newOrder <= 5);

        String newLeader = nextRoundLeader(
            getPlayers(store.state), roundLeader(store.state).order, isAuction(store.state));
        await createNewRound(store, currentHeistId, newOrder, newLeader);
      }
      return store.state.db.completeRound(round.id);
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

  Round newRound =
      new Round(leader: leader, order: order, heist: heistId, team: new Set(), startedAt: now());
  return db.upsertRound(newRound, roomId);
}
