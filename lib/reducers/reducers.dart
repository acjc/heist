import 'package:heist/state.dart';

import 'bid_amount_reducers.dart';
import 'form_reducers.dart';
import 'gift_amount_reducers.dart';
import 'haunt_reducers.dart';
import 'local_actions_reducers.dart';
import 'player_reducers.dart';
import 'request_reducers.dart';
import 'room_reducers.dart';
import 'round_reducers.dart';
import 'subscription_reducers.dart';

GameModel gameModelReducer(GameModel gameModel, dynamic action) => GameModel(
      db: gameModel.db,
      subscriptions: subscriptionReducer(gameModel.subscriptions, action),
      playerInstallId: playerInstallIdReducer(gameModel.playerInstallId, action),
      playerName: playerNameReducer(gameModel.playerName, action),
      roomCode: roomCodeReducer(gameModel.roomCode, action),
      bidAmount: bidAmountReducer(gameModel.bidAmount, action),
      giftAmount: giftAmountReducer(gameModel.giftAmount, action),
      requests: requestReducer(gameModel.requests, action),
      localActions: localActionsReducer(gameModel.localActions, action),
      room: roomReducer(gameModel.room, action),
      players: playerReducer(gameModel.players, action),
      haunts: hauntReducer(gameModel.haunts, action),
      rounds: roundReducer(gameModel.rounds, action),
    );

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
