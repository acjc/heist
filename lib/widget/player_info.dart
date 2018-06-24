part of heist;

Widget _playerInfo(Store<GameModel> store) {
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
          child: new Container(
            padding: paddingLarge,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new Text(
                  viewModel.me.name,
                  style: infoTextStyle,
                ),
                new Text(
                  viewModel.balance.toString(),
                  style: infoTextStyle,
                ),
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
