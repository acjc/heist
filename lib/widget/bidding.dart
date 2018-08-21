import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/reducers/bid_amount_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget bidAmount(BuildContext context, Store<GameModel> store, int bidAmount, int balance) =>
    new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconWidget(context, Icons.arrow_back, () => store.dispatch(new DecrementBidAmountAction())),
        new Text(bidAmount.toString(),
            style: const TextStyle(
              fontSize: 32.0,
            )),
        iconWidget(
            context,
            Icons.arrow_forward,
            () => store.dispatch(new IncrementBidAmountAction(
                balance, isAuction(store.state) ? 999 : currentHeist(store.state).maximumBid))),
      ],
    );

Widget submitButton(Store<GameModel> store, bool loading, int bidAmount) => new RaisedButton(
    child: const Text('SUBMIT BID', style: buttonTextStyle),
    onPressed: loading
        ? null
        : () => store.dispatch(new SubmitBidAction(getSelf(store.state).id, bidAmount)));

Widget cancelButton(BuildContext context, Store<GameModel> store, bool loading, Bid bid) =>
    new RaisedButton(
        color: Theme.of(context).accentColor,
        child: const Text('CANCEL BID', style: buttonTextStyle),
        onPressed: loading || bid == null ? null : () => store.dispatch(new CancelBidAction()));

Widget bidding(Store<GameModel> store) {
  return StoreConnector<GameModel, BiddingViewModel>(
      converter: (store) => new BiddingViewModel._(
          currentBalance(store.state),
          getBidAmount(store.state),
          requestInProcess(store.state, Request.Bidding),
          myCurrentBid(store.state),
          numBids(store.state)),
      distinct: true,
      builder: (context, viewModel) {
        String currentBidAmount = viewModel.bid == null
            ? 'None'
            : min(viewModel.bid.amount, viewModel.balance).toString();
        Heist heist = currentHeist(store.state);
        bool auction = isAuction(store.state);

        List<Widget> children = auction
            ? [
                new Container(
                  padding: paddingTitle,
                  child: const Text('AUCTION!', style: titleTextStyle),
                ),
                new Text('${heist.numPlayers} spots available! Highest, then fastest, bids win!',
                    style: infoTextStyle),
              ]
            : [
                new Container(
                  padding: paddingTitle,
                  child: const Text('BIDDING', style: titleTextStyle),
                ),
              ];

        String maximumBid = auction ? 'Unlimited' : heist.maximumBid.toString();
        children.addAll([
          new Text('Bids so far: ${viewModel.numBids} / ${getRoom(store.state).numPlayers}',
              style: infoTextStyle),
          new Text('Your bid: $currentBidAmount', style: infoTextStyle),
          new Text('Maximum bid: $maximumBid', style: infoTextStyle),
          bidAmount(context, store, viewModel.bidAmount, viewModel.balance),
          new Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            cancelButton(context, store, viewModel.loading, viewModel.bid),
            submitButton(store, viewModel.loading, viewModel.bidAmount),
          ]),
        ]);

        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                alignment: Alignment.center,
                child: new Column(
                  children: children,
                )));
      });
}

class BiddingViewModel {
  final int balance;
  final int bidAmount;
  final bool loading;
  final Bid bid;
  final int numBids;

  BiddingViewModel._(this.balance, this.bidAmount, this.loading, this.bid, this.numBids);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid &&
          numBids == other.numBids;

  @override
  int get hashCode =>
      balance.hashCode ^ bidAmount.hashCode ^ loading.hashCode ^ bid.hashCode ^ numBids.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{balance: $balance, bidAmount: $bidAmount, loading: $loading, bid: $bid, numBids: $numBids}';
  }
}
