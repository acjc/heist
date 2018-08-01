import 'dart:async';

import 'package:heist/reducers/request_reducers.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

import 'bidding_middleware.dart';
import 'game_middleware.dart';
import 'gifting_middleware.dart';
import 'heist_middleware.dart';
import 'room_middleware.dart';
import 'round_end_middleware.dart';
import 'team_picker_middleware.dart';

List<Middleware<GameModel>> createMiddleware() {
  List<Middleware<GameModel>> middleware = [
    new TypedMiddleware<GameModel, ValidateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SetUpNewGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, JoinGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SubmitBidAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CancelBidAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SendGiftAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, PickPlayerMiddlewareAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, RemovePlayerMiddlewareAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SubmitTeamAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, MakeDecisionAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, ResolveAuctionWinnersAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CompleteRoundAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CompleteHeistAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, CompleteGameAction>(_dispatchMiddleware),
  ];

  // asserts only work in debug mode
  assert(() {
    middleware.add(new LoggingMiddleware.printer());
    return true;
  }());

  return middleware;
}

/// Delegate middleware intercepts to the MiddlewareActions themselves.
void _dispatchMiddleware(Store<GameModel> store, dynamic action, NextDispatcher next) =>
    action.handle(store, action, next);

/// MiddlewareActions know how to handle themselves.
abstract class MiddlewareAction {
  Future<void> handle(Store<GameModel> store, dynamic action, NextDispatcher next);
}

/// Complete some asynchronous work using a request marker as a lock.
Future<T> withRequest<T>(
    Request request, Store<GameModel> store, Future<T> work(Store<GameModel> store)) async {
  store.dispatch(new StartRequestAction(request));
  T result = await work(store);
  store.dispatch(new RequestCompleteAction(request));
  return result;
}
