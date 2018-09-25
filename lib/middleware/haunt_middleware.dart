import 'dart:async';

import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class MakeDecisionAction extends MiddlewareAction {
  final String decision;

  MakeDecisionAction(this.decision);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) =>
      store.state.db.makeDecision(currentHaunt(store.state).id, getSelf(store.state).id, decision);
}

class CompleteHauntAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) => withRequest(
      Request.CompletingHaunt,
      store,
      (store) => store.state.db.completeHaunt(currentHaunt(store.state).id));
}
