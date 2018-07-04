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
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    // TODO: make new heist and round
    return store.state.db.completeHeist(currentHeist(store.state).id);
  }
}
