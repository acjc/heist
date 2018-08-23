import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget playerInfo(Store<GameModel> store) {
  return new StoreConnector<GameModel, PlayerInfoViewModel>(
      distinct: true,
      converter: (store) =>
          new PlayerInfoViewModel._(getSelf(store.state), currentBalance(store.state)),
      builder: (context, viewModel) {
        if (viewModel.me == null) {
          return new Container();
        }
        return new Card(
          elevation: 2.0,
          child: new Padding(
            padding: paddingMedium,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new Text(
                  '${viewModel.me.name} (${viewModel.me.order})',
                  style: infoTextStyle,
                ),
                new VerticalDivider(),
                new Column(children:[
                  new Text(
                    "Balance",
                    style: infoTextStyle,
                  ),
                  new Text(
                    viewModel.balance.toString(),
                    style: infoTextStyle,
                  ),
                ])
              ],
            ),
          ),
        );
      });
}

class PlayerInfoViewModel {
  final Player me;
  final int balance;

  PlayerInfoViewModel._(this.me, this.balance);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerInfoViewModel && me == other.me && balance == other.balance;

  @override
  int get hashCode => me.hashCode ^ balance.hashCode;

  @override
  String toString() {
    return '_PlayerInfoViewModel{me: $me, balance: $balance}';
  }
}
