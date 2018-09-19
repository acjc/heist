import 'dart:async';

import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class CompleteRoundAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) => withRequest(
      Request.CompletingRound,
      store,
      (store) => store.state.db.completeRound(currentRound(store.state).id));
}
