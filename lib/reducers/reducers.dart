import 'package:heist/state.dart';

import 'bid_amount_reducers.dart';
import 'gift_amount_reducers.dart';
import 'heist_reducers.dart';
import 'player_reducers.dart';
import 'request_reducers.dart';
import 'room_reducers.dart';
import 'round_reducers.dart';
import 'subscription_reducers.dart';

GameModel gameModelReducer(GameModel gameModel, dynamic action) {
  return new GameModel(
    db: gameModel.db,
    subscriptions: subscriptionReducer(gameModel.subscriptions, action),
    playerInstallId: playerInstallIdReducer(gameModel.playerInstallId, action),
    playerName: playerNameReducer(gameModel.playerName, action),
    bidAmount: bidAmountReducer(gameModel.bidAmount, action),
    giftAmount: giftAmountReducer(gameModel.giftAmount, action),
    requests: requestReducer(gameModel.requests, action),
    room: roomReducer(gameModel.room, action),
    players: playerReducer(gameModel.players, action),
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
