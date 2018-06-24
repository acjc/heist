part of heist;

Widget body(BuildContext context, BiddingViewModel viewModel) {
  Store<GameModel> store = StoreProvider.of<GameModel>(context);
  String currentBidAmount = viewModel.bid == null ? 'None' : viewModel.bid.amount.toString();
  return new Card(
      elevation: 2.0,
      child: new Container(
          padding: paddingLarge,
          child: new Column(
            children: [
              new Text('Bids so far: ${viewModel.numBids} / ${viewModel.numPlayers}',
                  style: infoTextStyle),
              new Text('Your bid: $currentBidAmount', style: infoTextStyle),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  iconWidget(context, Icons.arrow_back,
                      () => store.dispatch(new DecrementBidAmountAction())),
                  new Text('${viewModel.bidAmount}',
                      style: const TextStyle(
                        fontSize: 32.0,
                      )),
                  iconWidget(
                      context,
                      Icons.arrow_forward,
                      () => store
                          .dispatch(new IncrementBidAmountAction(currentBalance(store.state)))),
                ],
              ),
              new Container(
                  padding: paddingLarge,
                  child: new RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: const Text('SUBMIT BID', style: buttonTextStyle),
                      onPressed: viewModel.loading
                          ? null
                          : () => store.dispatch(new SubmitBidAction(viewModel.bidAmount)))),
              new RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: const Text('CANCEL BID', style: buttonTextStyle),
                  onPressed: viewModel.bid == null || viewModel.loading
                      ? null
                      : () => store.dispatch(new CancelBidAction()))
            ],
          )));
}

Widget bidding() {
  return new StoreConnector<GameModel, BiddingViewModel>(
    converter: (store) => new BiddingViewModel._(
        getBidAmount(store.state),
        requestInProcess(store.state, Request.Bidding),
        myCurrentBid(store.state),
        numBids(store.state),
        getRoom(store.state).numPlayers),
    distinct: true,
    builder: (context, viewModel) => new Column(children: [
          body(context, viewModel),
          selectionBoard(),
        ]),
  );
}

class BiddingViewModel {
  final int bidAmount;
  final bool loading;
  final Bid bid;
  final int numBids;
  final int numPlayers;

  BiddingViewModel._(this.bidAmount, this.loading, this.bid, this.numBids, this.numPlayers);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid &&
          numBids == other.numBids &&
          numPlayers == other.numPlayers;

  @override
  int get hashCode =>
      bidAmount.hashCode ^ loading.hashCode ^ bid.hashCode ^ numBids.hashCode ^ numPlayers.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{bidAmount: $bidAmount, loading: $loading, bid: $bid, numBids: $numBids, numPlayers: $numPlayers}';
  }
}
