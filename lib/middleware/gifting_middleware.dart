import 'dart:async';

import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class SendGiftAction extends MiddlewareAction {
  final String recipient;
  final int amount;

  SendGiftAction(this.recipient, this.amount);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(
        Request.Gifting,
        store,
        (store) => store.state.db.sendGift(currentRound(store.state).id, getSelf(store.state).id,
            new Gift(recipient: recipient, amount: amount)));
  }
}
