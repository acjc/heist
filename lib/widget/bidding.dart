import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/reducers/bid_amount_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget bidSelector(
    BuildContext context, Store<GameModel> store, int bidAmount, int balance, int maximumBid) {
  int upperBound = min(maximumBid, balance);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      iconWidget(
        context,
        Icons.arrow_back,
        () => store.dispatch(DecrementBidAmountAction()),
        bidAmount > 0,
      ),
      Text(
        bidAmount.toString(),
        style: bigNumberTextStyle,
      ),
      iconWidget(
        context,
        Icons.arrow_forward,
        () => store.dispatch(IncrementBidAmountAction(upperBound)),
        bidAmount < upperBound,
      ),
    ],
  );
}

Widget submitButton(BuildContext context, Store<GameModel> store, bool loading, int bidAmount) =>
    RaisedButton(
        child: Text(AppLocalizations.of(context).submitBid, style: buttonTextStyle),
        onPressed: loading
            ? null
            : () => store.dispatch(SubmitBidAction(getSelf(store.state).id, bidAmount)));

Widget cancelButton(BuildContext context, Store<GameModel> store, bool loading, Bid bid) =>
    RaisedButton(
        color: HeistColors.peach,
        child: Text(AppLocalizations.of(context).cancelBid, style: buttonTextStyle),
        onPressed: loading || bid == null ? null : () => store.dispatch(CancelBidAction()));

Widget bidding(Store<GameModel> store) => StoreConnector<GameModel, BiddingViewModel>(
    converter: (store) => BiddingViewModel._(
          currentBalance(store.state),
          getBidAmount(store.state),
          requestInProcess(store.state, Request.Bidding),
          myCurrentBid(store.state),
          bidderNames(store.state),
          haveGuessedBrenda(store.state),
        ),
    distinct: true,
    builder: (context, viewModel) {
      Haunt heist = currentHaunt(store.state);
      bool auction = isAuction(store.state);

      List<Widget> children = auction
          ? [
              Container(
                padding: paddingTitle,
                child: Text(AppLocalizations.of(context).auctionTitle.toUpperCase(),
                    style: titleTextStyle),
              ),
              Text(
                AppLocalizations.of(context).auctionDescription(heist.numPlayers),
                style: infoTextStyle,
              ),
            ]
          : [
              Container(
                padding: paddingTitle,
                child: Text(
                  AppLocalizations.of(context).bidding,
                  style: titleTextStyle,
                ),
              ),
            ];

      String proposedBidText = viewModel.bid == null
          ? AppLocalizations.of(context).noBid
          : viewModel.bid.amount.toString();
      children.addAll([
        Container(
          padding: paddingSmall,
          child: iconText(
            Icon(
              Icons.attach_money,
              size: 32.0,
            ),
            Text(
              proposedBidText,
              style: bigNumberTextStyle,
            ),
          ),
        ),
      ]);

      if (auction || viewModel.haveGuessedKingpin) {
        children.add(
          Text(
            AppLocalizations.of(context).unlimited,
            style: Theme.of(context).textTheme.caption.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }

      int proposedBid = viewModel.bid == null ? 0 : viewModel.bid.amount;
      int potentialBalance = viewModel.balance + proposedBid;
      int maximumBid = auction || viewModel.haveGuessedKingpin ? 999 : heist.maximumBid;
      children.addAll([
        bidSelector(
          context,
          store,
          min(viewModel.bidAmount, min(maximumBid, potentialBalance)),
          potentialBalance,
          maximumBid,
        ),
        Padding(
          padding: paddingSmall,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              cancelButton(context, store, viewModel.loading, viewModel.bid),
              submitButton(context, store, viewModel.loading, viewModel.bidAmount),
            ],
          ),
        ),
        Padding(
          padding: paddingSmall,
          child: Column(
            children: [
              Text(
                  AppLocalizations.of(context)
                      .bidders(viewModel.bidders.length, getRoom(store.state).numPlayers),
                  style: infoTextStyle),
              Column(
                children: List.generate(
                  viewModel.bidders.length,
                  (i) => Text(
                        viewModel.bidders.elementAt(i),
                        style: Theme.of(context).textTheme.caption,
                      ),
                ),
              ),
            ],
          ),
        ),
      ]);

      return Card(
          elevation: 2.0,
          child: Container(
              padding: paddingLarge,
              alignment: Alignment.center,
              child: Column(
                children: children,
              )));
    });

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
