part of heist;

GameModel gameModelReducer(GameModel gameModel, dynamic action) {
  return new GameModel(
    subscriptions: subscriptionReducer(gameModel.subscriptions, action),
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

/// Use to replace a value for a key in map state.
class UpdateMapEntryAction<Key, Value> extends Action<Map<Key, Value>> {
  final Key key;
  final Value value;

  UpdateMapEntryAction(this.key, this.value);

  @override
  Map<Key, Value> reduce(Map<Key, Value> state, action) {
    Map<Key, Value> updated = new Map.from(state);
    updated[key] = value;
    return updated;
  }
}
