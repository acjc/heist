part of heist;

class Game extends StatelessWidget {
  static const EdgeInsets _padding = const EdgeInsets.all(24.0);
  static const TextStyle _textStyle = const TextStyle(fontSize: 16.0);

  Widget _loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: _textStyle,
    ));
  }

  Widget _mainBoardBody(Store<GameModel> store, GameModel viewModel) {
    if (!viewModel.roomIsAvailable()) {
      return _loading();
    }

    if (viewModel.waitingForPlayers()) {
      return new Center(
          child: new Text(
        "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
        style: Game._textStyle,
      ));
    }

    if (viewModel.isNewGame()) {
      return new Center(
          child: new Text(
        "Assigning roles...",
        style: Game._textStyle,
      ));
    }

    if (!viewModel.ready()) {
      return _loading();
    }

    Player me = viewModel.me();
    return new ListTile(
      title: new Text(
        "${viewModel.room.code} - ${viewModel.room.numPlayers} players",
        style: _textStyle,
      ),
      subtitle: new Text(
        "${me.name} (${me.role})",
        style: _textStyle,
      ),
    );
  }

  Widget _mainBoard(Store<GameModel> store) {
    return new StoreConnector<GameModel, GameModel>(
        onInit: (store) => store.dispatch(new LoadGameAction()),
        onDispose: (store) => _resetGameStore(store),
        converter: (store) => store.state,
        builder: (context, viewModel) => new Expanded(
              child: new Card(
                elevation: 2.0,
                child: _mainBoardBody(store, viewModel),
              ),
            ));
  }

  Widget _playerInfo(Store<GameModel> store) {
    return new StoreConnector<GameModel, _PlayerInfoViewModel>(
        converter: (store) =>
            new _PlayerInfoViewModel(store.state.me(), store.state.getCurrentBalance()),
        builder: (context, viewModel) {
          if (!store.state.ready()) {
            return new Container();
          }
          return new Card(
            elevation: 2.0,
            child: new Container(
              padding: _padding,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new Text(
                    viewModel.me.name,
                    style: _textStyle,
                  ),
                  new Text(
                    viewModel.balance.toString(),
                    style: _textStyle,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _gameHistory(Store<GameModel> store) {
    return new StoreConnector<GameModel, List<Heist>>(
        converter: (store) => store.state.heists,
        builder: (context, viewModel) {
          if (!store.state.ready()) {
            return new Container();
          }
          return new Card(
              elevation: 2.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: new List.generate(5, (i) {
                  int price = i < viewModel.length ? viewModel[i].price : -1;
                  return new Container(
                    padding: _padding,
                    child: new Text("$price"),
                  );
                }),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
        ),
        body: new Column(children: [_playerInfo(store), _mainBoard(store), _gameHistory(store)]));
  }
}

void _resetGameStore(Store<GameModel> store) {
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(new Room.initial()));
  store.dispatch(new UpdateStateAction<Set<Player>>(new Set()));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}

class _PlayerInfoViewModel {
  final Player me;
  final int balance;

  _PlayerInfoViewModel(this.me, this.balance);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _PlayerInfoViewModel &&
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
