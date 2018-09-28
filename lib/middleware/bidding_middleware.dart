import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class SubmitBidAction extends MiddlewareAction {
  @required
  final String bidder;
  @required
  final String recipient;
  @required
  final int amount;

  SubmitBidAction({this.bidder, this.recipient, this.amount});

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(
        Request.Bidding,
        store,
        (store) =>
            store.state.db.submitBid(currentRound(store.state).id, bidder, Bid(recipient, amount)));
  }
}

class CancelBidAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    return withRequest(Request.Bidding, store,
        (store) => store.state.db.cancelBid(currentRound(store.state).id, getSelf(store.state).id));
  }
}
