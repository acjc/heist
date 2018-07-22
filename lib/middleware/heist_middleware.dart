import 'dart:async';

import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/request_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';
import 'round_end_middleware.dart';

class MakeDecisionAction extends MiddlewareAction {
  final String decision;

  MakeDecisionAction(this.decision);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db
        .makeDecision(currentHeist(store.state).id, getSelf(store.state).id, decision);
  }
}

class CompleteHeistAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.CompletingHeist));

    return withRequest(Request.CompletingHeist, store, (store) async {
      String currentHeistId = currentHeist(store.state).id;
      if (!gameOver(store.state)) {
        await toNextHeist(store);
      }
      return store.state.db.completeHeist(currentHeistId);
    });
  }

  Future<void> toNextHeist(Store<GameModel> store) async {
    String newLeader = nextRoundLeader(
        getPlayers(store.state), roundLeader(store.state).order, isAuction(store.state));

    List<Heist> heists = getHeists(store.state);
    assert(heists.where((h) => h.completedAt == null).length == 1);

    // TODO: create all heists up front
    int newOrder = heists.length + 1;
    String newHeistId = await _createNewHeist(store, newOrder);
    return createNewRound(store, newHeistId, 1, newLeader);
  }

  Future<String> _createNewHeist(Store<GameModel> store, int newOrder) async {
    Room room = getRoom(store.state);
    Heist existingHeist = await store.state.db.getHeist(room.id, newOrder);
    if (existingHeist != null) {
      return existingHeist.id;
    }
    HeistDefinition heistDefinition = heistDefinitions[room.numPlayers][newOrder];
    Heist newHeist = new Heist(
        price: heistDefinition.price,
        numPlayers: heistDefinition.numPlayers,
        maximumBid: heistDefinition.maximumBid,
        order: newOrder,
        startedAt: now());
    return store.state.db.upsertHeist(newHeist, room.id);
  }
}
