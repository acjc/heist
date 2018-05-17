part of heist;

GameModel gameModelReducer(GameModel gameModel, dynamic action) {
  return new GameModel(
      room: roomReducer(gameModel.room, action),
      player: playerReducer(gameModel.player, action),
      heists: heistReducer(gameModel.heists, action),
      rounds: roundReducer(gameModel.rounds, action),
  );
}

/// Actions know how to reduce themselves.
abstract class Action<State> {
  State reduce(State state, dynamic action);
}

/// Generic method to delegate reduction to the action itself.
State reduce<State>(State state, dynamic action) => action.reduce(state, action);

/// Use to completely replace part of the global state.
class UpdateStateAction<State> extends Action<State> {
  final State state;

  UpdateStateAction(this.state);

  @override
  State reduce(State state, action) {
    return this.state;
  }
}
