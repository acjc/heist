part of heist;

GameModel gameModelReducer(GameModel gameModel, dynamic action) {
  return new GameModel(
    db: gameModel.db,
    subscriptions: subscriptionReducer(gameModel.subscriptions, action),
    busy: busyReducer(gameModel.busy, action),
    room: roomReducer(gameModel.room, action),
    players: playerReducer(gameModel.players, action),
    heists: heistReducer(gameModel.heists, action),
    rounds: roundReducer(gameModel.rounds, action),
    currentBalance: gameModel.currentBalance,
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
    return this.state ?? state;
  }
}

/// Use to replace a value for a key in map state.
class UpdateMapEntryAction<Key, Value> extends Action<Map<Key, Value>> {
  final Key key;
  final Value value;

  UpdateMapEntryAction(this.key, this.value);

  @override
  Map<Key, Value> reduce(Map<Key, Value> state, action) {
    if (value == null) {
      return state;
    }
    Map<Key, Value> updated = state != null ? new Map.from(state) : new Map();
    updated[key] = value;
    return updated;
  }
}
