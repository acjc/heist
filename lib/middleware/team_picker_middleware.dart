part of heist;

class PickPlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  PickPlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateTeam(currentRound(store.state).id, playerId, true);
  }
}

class RemovePlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  RemovePlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateTeam(currentRound(store.state).id, playerId, false);
  }
}

class SubmitTeamAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.submitTeam(currentRound(store.state).id);
  }
}
