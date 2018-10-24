import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget playerInfo(Store<GameModel> store) => StoreConnector<GameModel, PlayerInfoViewModel>(
    distinct: true,
    converter: (store) => PlayerInfoViewModel._(
          getSelf(store.state),
          currentBalance(store.state),
          amountReceivedThisRound(store.state),
        ),
    builder: (context, viewModel) {
      if (viewModel.me == null) {
        return Container();
      }
      return TitledCard(
        title: AppLocalizations.of(context).playerInfo,
        child: Padding(
          padding: paddingMedium,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              roomCode(context, getRoom(store.state).code),
              VerticalDivider(),
              playerName(context, viewModel.me),
              VerticalDivider(),
              playerBalance(viewModel.balance, viewModel.amountReceivedThisRound),
            ],
          ),
        ),
      );
    });

Widget roomCode(BuildContext context, String code) => Column(
      children: [
        Text('Room', style: Theme.of(context).textTheme.caption),
        Text(code, style: Theme.of(context).textTheme.subhead),
      ],
    );

Widget playerBalance(int balance, int amountReceivedThisRound) {
  List<Widget> children = [
    Icon(Icons.bubble_chart, size: 32.0),
    Text(balance.toString(), style: bigNumberTextStyle),
  ];
  if (amountReceivedThisRound > 0) {
    children.addAll([
      Container(
        child: Text(
          '+$amountReceivedThisRound',
          style: const TextStyle(fontSize: 16.0, color: HeistColors.green),
        ),
        margin: const EdgeInsets.only(left: 8.0),
      ),
      Container(
        child: Icon(Icons.cake, size: 14.0, color: HeistColors.green),
        margin: const EdgeInsets.only(left: 2.0),
      ),
    ]);
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );
}

Widget playerName(BuildContext context, Player me) {
  List<Widget> children = [
    Text(
      me.name,
      style: Theme.of(context).textTheme.subhead,
    ),
  ];

  if (me.order != null) {
    children.add(
      Text(
        AppLocalizations.of(context).playerOrder(me.order),
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

class PlayerInfoViewModel {
  final Player me;
  final int balance;
  final int amountReceivedThisRound;

  PlayerInfoViewModel._(this.me, this.balance, this.amountReceivedThisRound);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerInfoViewModel &&
          runtimeType == other.runtimeType &&
          me == other.me &&
          balance == other.balance &&
          amountReceivedThisRound == other.amountReceivedThisRound;

  @override
  int get hashCode => me.hashCode ^ balance.hashCode ^ amountReceivedThisRound.hashCode;

  @override
  String toString() {
    return 'PlayerInfoViewModel{me: $me, balance: $balance, amountReceivedThisRound: $amountReceivedThisRound}';
  }
}
