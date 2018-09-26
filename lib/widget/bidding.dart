import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/reducers/bid_amount_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class Bidding extends StatefulWidget {
  final Store<GameModel> _store;

  Bidding(this._store);

  @override
  State<StatefulWidget> createState() => _BiddingState(_store);
}

class _BiddingState extends State<Bidding> {
  final Store<GameModel> store;
  Player bidRecipient;

  _BiddingState(this.store) {
    bidRecipient = getSelf(store.state);
  }

  Widget bidText(Bid bid) {
    String proposedBidText =
        bid == null ? AppLocalizations.of(context).noBid : bid.amount.toString();
    List<Widget> children = [
      iconText(
        Icon(
          Icons.attach_money,
          size: 32.0,
        ),
        Text(
          proposedBidText,
          style: bigNumberTextStyle,
        ),
      )
    ];
    if (bid != null) {
      children.add(Text('on ${getPlayerById(store.state, bid.recipient).name}'));
    }
    return Padding(
      padding: paddingSmall,
      child: Column(
        children: children,
      ),
    );
  }

  Widget bidSelector(int bidAmount, int balance, int maximumBid) {
    int upperBound = min(maximumBid, balance);
    return Padding(
      padding: paddingSmall,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          iconWidget(
            context,
            Icons.arrow_back,
            () => widget._store.dispatch(DecrementBidAmountAction()),
            bidAmount > 0,
          ),
          Text(bidAmount.toString(), style: bigNumberTextStyle),
          iconWidget(
            context,
            Icons.arrow_forward,
            () => widget._store.dispatch(IncrementBidAmountAction(upperBound)),
            bidAmount < upperBound,
          ),
        ],
      ),
    );
  }

  Widget bidRecipientDropdown() {
    Set<Player> included = currentInclusions(widget._store.state);
    Player startingValue = included.contains(bidRecipient) ? bidRecipient : included.elementAt(0);
    bidRecipient = startingValue;
    return Padding(
      padding: paddingSmall,
      child: Column(
        children: [
          Text('Choose a player to bid on:', style: infoTextStyle),
          DropdownButton<Player>(
            items: included
                .map((p) => DropdownMenuItem<Player>(
                      value: p,
                      child: Text(p.name, style: dropdownTextStyle),
                    ))
                .toList(),
            onChanged: (newValue) => bidRecipient = newValue,
            value: startingValue,
          ),
        ],
      ),
    );
  }

  Widget submitButton(int bidAmount, bool enabled) => RaisedButton(
      child: Text(AppLocalizations.of(context).submitBid, style: buttonTextStyle),
      onPressed: enabled
          ? () => widget._store.dispatch(SubmitBidAction(
                bidder: getSelf(widget._store.state).id,
                recipient: bidRecipient.id,
                amount: bidAmount,
              ))
          : null);

  Widget cancelButton(bool enabled) => RaisedButton(
      color: Theme.of(context).accentColor,
      child: Text(AppLocalizations.of(context).cancelBid, style: buttonTextStyle),
      onPressed: enabled ? () => widget._store.dispatch(CancelBidAction()) : null);

  Widget biddersSoFar(Set<String> bidderNames) => Padding(
        padding: paddingSmall,
        child: Column(
          children: [
            Text(
                AppLocalizations.of(context)
                    .bidders(bidderNames.length, getRoom(widget._store.state).numPlayers),
                style: infoTextStyle),
            Column(
              children: List.generate(
                bidderNames.length,
                (i) => Text(bidderNames.elementAt(i), style: subtitleTextStyle),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, BiddingViewModel>(
      distinct: true,
      converter: (store) => BiddingViewModel._(
            balance: currentBalance(store.state),
            bidAmount: getBidAmount(store.state),
            loading: requestInProcess(store.state, Request.Bidding),
            bid: myCurrentBid(store.state),
            bidderNames: bidderNames(store.state),
            haveGuessedBrenda: haveGuessedBrenda(store.state),
          ),
      builder: (context, viewModel) {
        Haunt heist = currentHaunt(widget._store.state);
        bool auction = isAuction(widget._store.state);

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

        children.add(bidText(viewModel.bid));

        if (auction || viewModel.haveGuessedBrenda) {
          children.add(
            Text(
              AppLocalizations.of(context).unlimited,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }

        int proposedBid = viewModel.bid == null ? 0 : viewModel.bid.amount;
        int potentialBalance = viewModel.balance + proposedBid;
        int maximumBid = auction || viewModel.haveGuessedBrenda ? 999 : heist.maximumBid;
        children.add(
          bidSelector(
            min(viewModel.bidAmount, min(maximumBid, potentialBalance)),
            potentialBalance,
            maximumBid,
          ),
        );

        if (!auction) {
          children.add(bidRecipientDropdown());
        }

        children.addAll([
          Padding(
            padding: paddingSmall,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                cancelButton(!viewModel.loading && viewModel.bid != null),
                submitButton(viewModel.bidAmount, !viewModel.loading),
              ],
            ),
          ),
          biddersSoFar(viewModel.bidderNames),
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
}

class BiddingViewModel {
  @required
  final int balance;
  @required
  final int bidAmount;
  @required
  final bool loading;
  @required
  final Bid bid;
  @required
  final Set<String> bidderNames;
  @required
  final bool haveGuessedBrenda;

  BiddingViewModel._({
    this.balance,
    this.bidAmount,
    this.loading,
    this.bid,
    this.bidderNames,
    this.haveGuessedBrenda,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid &&
          bidderNames == other.bidderNames &&
          haveGuessedBrenda == other.haveGuessedBrenda;

  @override
  int get hashCode =>
      balance.hashCode ^
      bidAmount.hashCode ^
      loading.hashCode ^
      bid.hashCode ^
      bidderNames.hashCode ^
      haveGuessedBrenda.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{balance: $balance, bidAmount: $bidAmount, loading: $loading, bid: $bid, bidderNames: $bidderNames, haveGuessedBrenda: $haveGuessedBrenda}';
  }
}
