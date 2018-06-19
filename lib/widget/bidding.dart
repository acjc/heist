part of heist;

class Bidding extends StatefulWidget {
  final Store<GameModel> store;

  Bidding(this.store);

  @override
  State<StatefulWidget> createState() {
    return new BiddingState(store);
  }
}

class BiddingState extends State<Bidding> {
  final Store<GameModel> store;

  BiddingState(this.store);

  Widget body(BuildContext context, BiddingViewModel viewModel) {
    return new Container(
        padding: padding,
        child: new Column(
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                iconWidget(context, Icons.arrow_back,
                    () => store.dispatch(new DecrementBidAmountAction())),
                new Text('${viewModel.bidAmount}',
                    style: const TextStyle(
                      fontSize: 32.0,
                    )),
                iconWidget(context, Icons.arrow_forward,
                    () => store.dispatch(new IncrementBidAmountAction(viewModel.balance))),
              ],
            ),
            new RaisedButton(
                color: Theme.of(context).primaryColor,
                child: const Text('SUBMIT BID', style: buttonTextStyle),
                onPressed: () {
                  store.dispatch(new SubmitBidAction(viewModel.bidAmount));
                }),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<GameModel, BiddingViewModel>(
      converter: (store) => new BiddingViewModel._(
          currentBalance(store.state),
          getBidAmount(store.state),
          requestInProcess(store.state, Request.Bidding),
          currentBid(store.state)),
      distinct: true,
      builder: (context, viewModel) => body(context, viewModel),
    );
  }
}

class BiddingViewModel {
  final int balance;
  final int bidAmount;
  final bool loading;
  final Bid bid;

  BiddingViewModel._(this.balance, this.bidAmount, this.loading, this.bid);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          balance == other.balance &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid;

  @override
  int get hashCode => balance.hashCode ^ bidAmount.hashCode ^ loading.hashCode ^ bid.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{balance: $balance, bidAmount: $bidAmount, loading: $loading, bid: $bid}';
  }
}
