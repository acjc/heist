part of heist;

class Game extends StatelessWidget {
  static const TextStyle standard = const TextStyle(fontSize: 16.0);

  void reloadSubscriptions(Store<GameModel> store) {
    store.dispatch(new CancelSubscriptionsAction());
    store.dispatch(new LoadGameAction());
  }

  Widget _loading() {
    return new Center(
        child: new Text(
      'Loading...',
      style: standard,
    ));
  }

  Widget _waitForPlayers(GameModel viewModel) {
    // TODO: add self to game if not yet added
    return new Center(
        child: new Text(
      "Waiting for players: ${viewModel.players.length} / ${viewModel.room.numPlayers}",
      style: standard,
    ));
  }

  void _assignRoles(GameModel viewModel) {
    List<String> roles = new List.of(viewModel.room.roles);
    assert(roles.length == viewModel.players.length);
    Random random = new Random();
    for (Player player in viewModel.players.where((p) => p.role == null || p.role.isEmpty)) {
      String role = roles.removeAt(random.nextInt(roles.length));
      viewModel.db.upsertPlayer(player.copyWith(role: role));
    }
  }

  Future<String> _createFirstHeist(GameModel viewModel) async {
    String roomId = viewModel.room.id;
    FirestoreDb db = viewModel.db;
    if (viewModel.heists.isEmpty && !(await db.heistExists(roomId, 1))) {
      Heist heist =
          new Heist(price: 12, numPlayers: 2, order: 1, startedAt: new DateTime.now().toUtc());
      return db.upsertHeist(heist, roomId);
    }
    return viewModel.heists[0].id;
  }

  Future<void> _createFirstRound(GameModel viewModel, String heistId) async {
    String roomId = viewModel.room.id;
    FirestoreDb db = viewModel.db;
    if (!viewModel.hasRounds() && !(await db.roundExists(roomId, heistId, 1))) {
      Round round = new Round(order: 1, startedAt: new DateTime.now().toUtc());
      return db.upsertRound(round, roomId, heistId);
    }
  }

  Widget _setUpNewGame(Store<GameModel> store, GameModel viewModel) {
    print("busy = ${viewModel.busy}");
    if (viewModel.amOwner() && !viewModel.busy) {
      store.dispatch(new MarkAsBusyAction());
      _assignRoles(viewModel);
      _createFirstHeist(viewModel)
          .then((heistId) => _createFirstRound(viewModel, heistId))
          .then((v) => reloadSubscriptions(store));
    }
    return new Center(
        child: new Text(
      "Assigning roles...",
      style: standard,
    ));
  }

  Widget _body(Store<GameModel> store, GameModel viewModel) {
    if (viewModel.isLoading()) {
      return _loading();
    }

    if (viewModel.waitingForPlayers()) {
      return _waitForPlayers(viewModel);
    }

    if (viewModel.isNewGame()) {
      return _setUpNewGame(store, viewModel);
    }

    if (viewModel.busy) {
      store.dispatch(new UnmarkAsBusyAction());
    }

    if (!viewModel.isReady()) {
      return _loading();
    }

    Player me = viewModel.me();
    return new ListTile(
      title: new Text("${viewModel.room.code} - ${viewModel.room.numPlayers} players"),
      subtitle: new Text("${me.name} (${me.role})"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Store<GameModel> store = StoreProvider.of<GameModel>(context);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${store.state.room.code}"),
        ),
        body: new StoreConnector<GameModel, GameModel>(
          onInit: (store) => store.dispatch(new LoadGameAction()),
          onDispose: (store) => store.dispatch(new CancelSubscriptionsAction()),
          converter: (store) => store.state,
          builder: (context, viewModel) => new Card(
                elevation: 2.0,
                child: _body(store, viewModel),
              ),
        ));
  }
}
