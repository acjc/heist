import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/gifting_middleware.dart';
import 'package:heist/reducers/gift_amount_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget giftSelector(BuildContext context, Store<GameModel> store, int giftAmount, int balance) =>
    new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconWidget(
            context, Icons.arrow_back, () => store.dispatch(new DecrementGiftAmountAction())),
        new Text(
          giftAmount.toString(),
          style: bigNumberTextStyle,
        ),
        iconWidget(context, Icons.arrow_forward,
            () => store.dispatch(new IncrementGiftAmountAction(balance))),
      ],
    );

Widget recipientSelection(Store<GameModel> store, int giftAmount, bool loading) {
  List<Player> otherPlayers = getOtherPlayers(store.state);
  return new GridView.count(
      padding: paddingMedium,
      shrinkWrap: true,
      childAspectRatio: 6.0,
      crossAxisCount: 2,
      primary: false,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      children: new List.generate(otherPlayers.length, (i) {
        Player player = otherPlayers[i];
        return new RaisedButton(
          child: new Text(player.name, style: buttonTextStyle),
          onPressed: loading || giftAmount <= 0
              ? null
              : () => store.dispatch(new SendGiftAction(player.id, giftAmount)),
        );
      }));
}

Widget gifting(Store<GameModel> store) => new StoreConnector<GameModel, GiftingViewModel>(
    converter: (store) => new GiftingViewModel._(
        currentBalance(store.state),
        myCurrentGift(store.state),
        getGiftAmount(store.state),
        requestInProcess(store.state, Request.Gifting)),
    distinct: true,
    builder: (context, viewModel) {
      List<Widget> children = [
        new Container(
          padding: paddingTitle,
          child: const Text('GIFTING', style: titleTextStyle),
        ),
      ];

      if (viewModel.gift != null) {
        String recipientName = getPlayerById(store.state, viewModel.gift.recipient).name;
        children.add(new Container(
            padding: paddingMedium,
            child: new Text(
                'You have already sent a gift this round of ${viewModel.gift.amount} to $recipientName',
                style: infoTextStyle)));
      } else {
        children.addAll([
          giftSelector(
              context, store, min(viewModel.giftAmount, viewModel.balance), viewModel.balance),
          const Text('Choose a player to send a gift to:', style: infoTextStyle),
          recipientSelection(store, viewModel.giftAmount, viewModel.loading),
        ]);
      }

      return new Card(
        elevation: 2.0,
        child: new Container(
            padding: paddingLarge,
            child: new Column(
              children: children,
            )),
      );
    });

class GiftingViewModel {
  final int balance;
  final Gift gift;
  final int giftAmount;
  final bool loading;

  GiftingViewModel._(this.balance, this.gift, this.giftAmount, this.loading);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftingViewModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          gift == other.gift &&
          giftAmount == other.giftAmount &&
          loading == other.loading;

  @override
  int get hashCode => balance.hashCode ^ gift.hashCode ^ giftAmount.hashCode ^ loading.hashCode;

  @override
  String toString() {
    return 'GiftingViewModel{balance: $balance, gift: $gift, giftAmount: $giftAmount, loading: $loading}';
  }
}
