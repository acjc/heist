import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/gifting_middleware.dart';
import 'package:heist/reducers/gift_amount_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget giftSelector(BuildContext context, Store<GameModel> store, int giftAmount, int balance) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconWidget(
          context,
          Icons.arrow_back,
          () => store.dispatch(DecrementGiftAmountAction()),
          giftAmount > 0,
        ),
        Text(giftAmount.toString(), style: bigNumberTextStyle),
        iconWidget(
          context,
          Icons.arrow_forward,
          () => store.dispatch(IncrementGiftAmountAction(balance)),
          giftAmount < balance,
        ),
      ],
    );

Widget recipientSelection(
  BuildContext context,
  Store<GameModel> store,
  int giftAmount,
  bool loading,
) {
  List<Player> otherPlayers = getOtherPlayers(store.state);
  return TeamGridView(List.generate(otherPlayers.length, (i) {
    Player player = otherPlayers[i];
    return RaisedButton(
      child: Text(player.name, style: Theme.of(context).textTheme.button),
      onPressed: loading || giftAmount <= 0
          ? null
          : () => store.dispatch(SendGiftAction(player.id, giftAmount)),
    );
  }));
}

Widget gifting(Store<GameModel> store) => StoreConnector<GameModel, GiftingViewModel>(
    converter: (store) => GiftingViewModel._(
        currentBalance(store.state),
        myCurrentGift(store.state),
        getGiftAmount(store.state),
        requestInProcess(store.state, Request.Gifting)),
    distinct: true,
    builder: (context, viewModel) {
      List<Widget> children = [];
      if (viewModel.gift != null) {
        String recipientName = getPlayerById(store.state, viewModel.gift.recipient).name;
        children.add(Container(
            padding: paddingMedium,
            child: Text(
                AppLocalizations.of(context).giftAlreadySent(viewModel.gift.amount, recipientName),
                style: infoTextStyle)));
      } else {
        children.addAll(
          [
            giftSelector(
              context,
              store,
              min(viewModel.giftAmount, viewModel.balance),
              viewModel.balance,
            ),
            Text(AppLocalizations.of(context).chooseGiftRecipient, style: infoTextStyle),
            recipientSelection(context, store, viewModel.giftAmount, viewModel.loading),
          ],
        );
      }

      return TitledCard(
        title: AppLocalizations.of(context).giftingTitle,
        child: Container(
            padding: paddingMedium,
            child: Column(
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
