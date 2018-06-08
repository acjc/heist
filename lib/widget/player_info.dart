part of heist;

Widget _playerInfo(Store<GameModel> store) {
  return new StoreConnector<GameModel, PlayerInfoViewModel>(
      converter: (store) =>
      new PlayerInfoViewModel._(store.state.me(), store.state.getCurrentBalance()),
      builder: (context, viewModel) {
        if (!store.state.ready()) {
          return new Container();
        }
        return new Card(
          elevation: 2.0,
          child: new Container(
            padding: padding,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new Text(
                  viewModel.me.name,
                  style: textStyle,
                ),
                new Text(
                  viewModel.balance.toString(),
                  style: textStyle,
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
          other is PlayerInfoViewModel &&
              me == other.me &&
              balance == other.balance;

  @override
  int get hashCode =>
      me.hashCode ^
      balance.hashCode;

  @override
  String toString() {
    return '_PlayerInfoViewModel{me: $me, balance: $balance}';
  }
}
