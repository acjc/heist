import 'dart:async';

import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
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
        .makeDecision(currentHaunt(store.state).id, getSelf(store.state).id, decision);
  }
}

class CompleteHauntAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    store.dispatch(new StartRequestAction(Request.CompletingHeist));

    return withRequest(Request.CompletingHeist, store, (store) async {
      String currentHauntId = currentHaunt(store.state).id;
      if (!gameOver(store.state)) {
        await toNextHaunt(store);
      }
      return store.state.db.completeHaunt(currentHauntId);
    });
  }

  Future<void> toNextHaunt(Store<GameModel> store) async {
    String newLeader = nextRoundLeader(
        getPlayers(store.state), currentLeader(store.state).order, isAuction(store.state));

    List<Haunt> haunts = getHaunts(store.state);
    assert(haunts.where((h) => h.completedAt == null).length == 1);

    // TODO: create all haunts up front
    int newOrder = haunts.length + 1;
    String newHauntId = await _createNewHaunt(store, newOrder);
    return createNewRound(store, newHauntId, 1, newLeader);
  }

  Future<String> _createNewHaunt(Store<GameModel> store, int newOrder) async {
    Room room = getRoom(store.state);
    Haunt existingHaunt = await store.state.db.getHaunt(room.id, newOrder);
    if (existingHaunt != null) {
      return existingHaunt.id;
    }
    HauntDefinition hauntDefinition = hauntDefinitions[room.numPlayers][newOrder];
    Haunt newHaunt = new Haunt(
        price: hauntDefinition.price,
        numPlayers: hauntDefinition.numPlayers,
        maximumBid: hauntDefinition.maximumBid,
        order: newOrder,
        startedAt: now());
    return store.state.db.upsertHaunt(newHaunt, room.id);
  }
}
