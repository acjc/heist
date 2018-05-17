part of heist;

List<Middleware<GameModel>> createMiddleware() {
  return [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, EnterRoomAction>(_dispatchMiddleware),
  ];
}

/// Delegate middleware intercepts to the MiddlewareActions themselves.
void _dispatchMiddleware(Store<GameModel> store, dynamic action, NextDispatcher next) =>
    action.handle(store, action, next);

/// MiddlewareActions know how to handle themselves.
abstract class MiddlewareAction {
  void handle(Store<GameModel> store, dynamic action, NextDispatcher next);
}
