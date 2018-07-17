part of heist;

Widget bidAmount(BuildContext context, Store<GameModel> store, int bidAmount) => new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconWidget(context, Icons.arrow_back, () => store.dispatch(new DecrementBidAmountAction())),
        new Text(bidAmount.toString(),
            style: const TextStyle(
              fontSize: 32.0,
            )),
        iconWidget(
            context,
            Icons.arrow_forward,
            () => store.dispatch(new IncrementBidAmountAction(
                currentBalance(store.state), currentHeist(store.state).maximumBid))),
      ],
    );

Widget submitButton(Store<GameModel> store, bool loading, int bidAmount) => new RaisedButton(
    child: const Text('SUBMIT BID', style: buttonTextStyle),
    onPressed: loading
        ? null
        : () => store.dispatch(new SubmitBidAction(getSelf(store.state).id, bidAmount)));

Widget cancelButton(BuildContext context, Store<GameModel> store, bool loading, Bid bid) =>
    new RaisedButton(
        color: Theme.of(context).accentColor,
        child: const Text('CANCEL BID', style: buttonTextStyle),
        onPressed: loading || bid == null ? null : () => store.dispatch(new CancelBidAction()));

Widget bidding(Store<GameModel> store) {
  return StoreConnector<GameModel, BiddingViewModel>(
      converter: (store) => new BiddingViewModel._(
          getBidAmount(store.state),
          requestInProcess(store.state, Request.Bidding),
          myCurrentBid(store.state),
          numBids(store.state)),
      distinct: true,
      builder: (context, viewModel) {
        String currentBidAmount = viewModel.bid == null ? 'None' : viewModel.bid.amount.toString();

        List<Widget> children = isAuction(store.state)
            ? [
                new Container(
                  padding: paddingTitle,
                  child: const Text('AUCTION!', style: titleTextStyle),
                ),
                new Text(
                    '${currentHeist(store.state).numPlayers} spots available! Highest, then fastest, bids win!',
                    style: infoTextStyle),
              ]
            : [
                new Container(
                  padding: paddingTitle,
                  child: const Text('BIDDING', style: titleTextStyle),
                ),
              ];
        children.addAll([
          new Text('Bids so far: ${viewModel.numBids} / ${getRoom(store.state).numPlayers}',
              style: infoTextStyle),
          new Text('Your bid: $currentBidAmount', style: infoTextStyle),
          bidAmount(context, store, viewModel.bidAmount),
          new Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            cancelButton(context, store, viewModel.loading, viewModel.bid),
            submitButton(store, viewModel.loading, viewModel.bidAmount),
          ]),
        ]);

        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                alignment: Alignment.center,
                child: new Column(
                  children: children,
                )));
      });
}

class BiddingViewModel {
  final int bidAmount;
  final bool loading;
  final Bid bid;
  final int numBids;

  BiddingViewModel._(this.bidAmount, this.loading, this.bid, this.numBids);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiddingViewModel &&
          bidAmount == other.bidAmount &&
          loading == other.loading &&
          bid == other.bid &&
          numBids == other.numBids;

  @override
  int get hashCode => bidAmount.hashCode ^ loading.hashCode ^ bid.hashCode ^ numBids.hashCode;

  @override
  String toString() {
    return 'BiddingViewModel{bidAmount: $bidAmount, loading: $loading, bid: $bid, numBids: $numBids}';
  }
}
