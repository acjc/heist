part of heist;

GameModel gameModelReducer(GameModel gameModel, dynamic action) {
  return new GameModel(room: roomReducer(gameModel.room, action));
}

/// Actions know how to reduce themselves.
abstract class Action<State> {
  State reduce(State state, dynamic action);
}

/// Generic method to delegate reduction to the action itself.
State _reduce<State>(State state, dynamic action) => action.reduce(state, action);
