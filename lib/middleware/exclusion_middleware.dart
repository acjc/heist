import 'dart:async';

import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class PickPlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  PickPlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateExclusions(currentRound(store.state).id, playerId, true);
  }
}

class RemovePlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  RemovePlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateExclusions(currentRound(store.state).id, playerId, false);
  }
}

class SubmitExclusionsAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(Request.SubmittingExclusions, store,
        (store) => store.state.db.submitExclusions(currentRound(store.state).id));
  }
}
