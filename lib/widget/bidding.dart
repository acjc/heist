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

Widget bidSelector(BuildContext context, Store<GameModel> store, int bidAmount, int balance,
        Heist heist, bool unlimited) =>
    new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconWidget(context, Icons.arrow_back, () => store.dispatch(new DecrementBidAmountAction())),
        new Text(
          bidAmount.toString(),
          style: bigNumberTextStyle,
        ),
        iconWidget(
            context,
            Icons.arrow_forward,
            () => store.dispatch(
                new IncrementBidAmountAction(balance, unlimited ? 999 : heist.maximumBid))),
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
            bidderNames(store.state),
            haveGuessedKingpin(store.state),
          ),
      distinct: true,
      builder: (context, viewModel) {
        String currentBid = viewModel.bid == null ? 'None' : viewModel.bid.amount.toString();
        Heist heist = currentHeist(store.state);
        bool auction = isAuction(store.state);

        List<Widget> children = auction
            ? [
                new Container(
                  padding: paddingTitle,
                  child: const Text('AUCTION!', style: titleTextStyle),
                ),
                new Text(
                  '${heist.numPlayers} spots available! Highest, then fastest, bids win!',
                  style: infoTextStyle,
                ),
              ]
            : [
                new Container(
                  padding: paddingTitle,
                  child: const Text(
                    'BIDDING',
                    style: titleTextStyle,
                  ),
                ),
              ];

        String maximumBid =
            auction || viewModel.haveGuessedKingpin ? 'Unlimited' : heist.maximumBid.toString();
        children.addAll([
          new Text(
              'Bidders so far (${viewModel.bidders.length} / ${getRoom(store.state).numPlayers}):',
              style: infoTextStyle),
          new Column(
            children: new List.generate(
              viewModel.bidders.length,
              (i) => new Text(viewModel.bidders.elementAt(i), style: subtitleTextStyle),
            ),
          ),
          new Padding(
            padding: paddingSmall,
            child: new Text('Your bid: $currentBid', style: infoTextStyle),
          ),
          new Text('Maximum bid: $maximumBid', style: infoTextStyle),
          bidSelector(
            context,
            store,
            min(viewModel.bidAmount, viewModel.balance),
            viewModel.balance,
            heist,
            auction || viewModel.haveGuessedKingpin,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              cancelButton(context, store, viewModel.loading, viewModel.bid),
              submitButton(store, viewModel.loading, viewModel.bidAmount),
            ],
          ),
        ]);

        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingLarge,
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
  final Set<String> bidders;
  final bool haveGuessedKingpin;

  BiddingViewModel._(
    this.balance,
    this.bidAmount,
    this.loading,
    this.bid,
    this.bidders,
    this.haveGuessedKingpin,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid &&
          bidders == other.bidders &&
          haveGuessedKingpin == other.haveGuessedKingpin;

  @override
  int get hashCode =>
      balance.hashCode ^
      bidAmount.hashCode ^
      loading.hashCode ^
      bid.hashCode ^
      bidders.hashCode ^
      haveGuessedKingpin.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{balance: $balance, bidAmount: $bidAmount, loading: $loading, bid: $bid, bidders: $bidders, haveGuessedKingpin: $haveGuessedKingpin}';
  }
}
