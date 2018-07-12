part of heist;

class MakeDecisionAction extends MiddlewareAction {
  final String decision;

  MakeDecisionAction(this.decision);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db
        .makeDecision(currentHeist(store.state).id, getSelf(store.state).id, decision);
  }
}

class CompleteHeistAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.CompletingHeist));

    return withRequest(Request.CompletingHeist, store, (store) async {
      String currentHeistId = currentHeist(store.state).id;
      if (!gameOver(store.state)) {
        await toNextHeist(store);
      }
      return store.state.db.completeHeist(currentHeistId);
    });
  }

  Future<void> toNextHeist(Store<GameModel> store) async {
    String newLeader = nextRoundLeader(
        getPlayers(store.state), roundLeader(store.state).order, isAuction(store.state));

    FirestoreDb db = store.state.db;
    Room room = getRoom(store.state);
    List<Heist> heists = getHeists(store.state);
    assert(heists.where((h) => h.completedAt == null).length == 1);

    int newOrder = heists.length + 1;
    assert(await db.getHeist(room.id, newOrder) == null);

    String newHeistId = await _createNewHeist(store, room, newOrder);
    return createNewRound(store, newHeistId, 1, newLeader);
  }

  Future<String> _createNewHeist(Store<GameModel> store, Room room, int newOrder) async {
    HeistDefinition heistDefinition = heistDefinitions[room.numPlayers][newOrder];
    Heist newHeist = new Heist(
        price: heistDefinition.price,
        numPlayers: heistDefinition.numPlayers,
        order: newOrder,
        startedAt: now());
    return store.state.db.upsertHeist(newHeist, room.id);
  }
}
