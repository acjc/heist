import 'dart:async';

import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class PickPlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  PickPlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateTeam(currentRound(store.state).id, playerId, true);
  }
}

class RemovePlayerMiddlewareAction extends MiddlewareAction {
  final String playerId;

  RemovePlayerMiddlewareAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return store.state.db.updateTeam(currentRound(store.state).id, playerId, false);
  }
}

class AuctionBid {
  final String playerId;
  final Bid bid;

  AuctionBid._(this.playerId, this.bid);
}

class ResolveAuctionWinnersAction extends MiddlewareAction {
  List<String> _winners(Map<String, Bid> bids, int numPlayers) {
    List<AuctionBid> auctionBids = [];
    bids.forEach((playerId, bid) => auctionBids.add(new AuctionBid._(playerId, bid)));
    auctionBids.sort((a1, a2) {
      int amountComparison = a2.bid.amount.compareTo(a1.bid.amount);
      return amountComparison != 0
          ? amountComparison
          : a1.bid.timestamp.compareTo(a2.bid.timestamp);
    });
    return auctionBids.map((a) => a.playerId).take(numPlayers).toList();
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(Request.ResolvingAuction, store, (store) async {
      Round round = currentRound(store.state);
      int numPlayers = currentHaunt(store.state).numPlayers;
      List<String> winners = _winners(round.bids, numPlayers);
      for (String playerId in winners) {
        await store.state.db.updateTeam(round.id, playerId, true);
      }
      await store.state.db.submitTeam(round.id);
    });
  }
}

class SubmitTeamAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(Request.SubmittingTeam, store,
        (store) => store.state.db.submitTeam(currentRound(store.state).id));
  }
}
