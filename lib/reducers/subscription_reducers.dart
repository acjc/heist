part of heist;

final subscriptionReducer = combineReducers<Subscriptions>([
  new TypedReducer<Subscriptions, AddSubscriptionsAction>(reduce),
  new TypedReducer<Subscriptions, CancelSubscriptionsAction>(reduce),
]);

class AddSubscriptionsAction extends Action<Subscriptions> {

  final Subscriptions subscriptions;

  AddSubscriptionsAction(this.subscriptions);

  @override
  Subscriptions reduce(Subscriptions subscriptions, action) {
    debugPrint('Subscribe firestore listeners');
    return this.subscriptions;
  }
}

class CancelSubscriptionsAction extends Action<Subscriptions> {

  @override
  Subscriptions reduce(Subscriptions subscriptions, action) {
    debugPrint('Unsubscribe firestore listeners');
    for (StreamSubscription<QuerySnapshot> sub in subscriptions.subs) {
      sub.cancel();
    }
    return new Subscriptions(subs: []);
  }
}
