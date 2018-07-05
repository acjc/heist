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
    String currentHeistId = currentHeist(store.state).id;
    await createNewHeist(store);
    await store.state.db.completeHeist(currentHeistId);
    store.dispatch(new RequestCompleteAction(Request.CompletingHeist));
  }

  Future<void> createNewHeist(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    Room room = getRoom(store.state);
    List<Heist> heists = getHeists(store.state);
    assert(heists.where((h) => !h.completed).length == 1);

    int newOrder = heists.last.order + 1;
    assert(await db.getHeist(room.id, newOrder) == null);

    HeistDefinition heistDefinition = heistDefinitions[room.numPlayers][newOrder];
    Heist newHeist = new Heist(
        price: heistDefinition.price,
        numPlayers: heistDefinition.numPlayers,
        order: newOrder,
        startedAt: now());
    return db.upsertHeist(newHeist, room.id);
  }
}
