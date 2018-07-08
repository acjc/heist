part of heist;

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
