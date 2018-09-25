import 'dart:async';

import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class CompleteRoundAction extends MiddlewareAction {
  final String roundId;

  CompleteRoundAction(this.roundId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) =>
      withRequest(Request.CompletingRound, store, (store) => store.state.db.completeRound(roundId));
}
