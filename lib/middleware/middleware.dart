part of heist;

List<Middleware<GameModel>> createMiddleware() {
  List<Middleware<GameModel>> middleware = [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SetUpNewGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, JoinGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SubmitBidAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CancelBidAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, PickPlayerMiddlewareAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, RemovePlayerMiddlewareAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SubmitTeamAction>(_dispatchMiddleware),
  ];

  // asserts only work in debug mode
  assert(() {
    middleware.add(new LoggingMiddleware.printer());
    return true;
  }());

  return middleware;
}

/// Delegate middleware intercepts to the MiddlewareActions themselves.
void _dispatchMiddleware(Store<GameModel> store, dynamic action, NextDispatcher next) =>
    action.handle(store, action, next);

/// MiddlewareActions know how to handle themselves.
abstract class MiddlewareAction {
  Future<void> handle(Store<GameModel> store, dynamic action, NextDispatcher next);
}
