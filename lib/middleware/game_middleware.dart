part of heist;

void _reloadSubscriptions(Store<GameModel> store) {
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new LoadGameAction());
}

class JoinGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String roomId = store.state.room.id;
    assert(roomId != null);
    String playerName = store.state.playerName;
    assert(playerName != null && playerName.isNotEmpty);

    FirestoreDb db = store.state.db;
    String iid = installId();

    if (!haveJoinedGame(store.state) && !(await db.playerExists(roomId, iid))) {
      // TODO: initial balance may eventually depend on role
      return db.upsertPlayer(
          new Player(installId: iid, name: playerName, initialBalance: 8), roomId);
    }
  }
}

class SetUpNewGameAction extends MiddlewareAction {
  void _assignRoles(Store<GameModel> store) {
    List<String> roles = new List.of(store.state.room.roles);
    assert(roles.length == store.state.players.length);
    Random random = new Random();
    for (Player player in store.state.players.where((p) => p.role == null || p.role.isEmpty)) {
      String role = roles.removeAt(random.nextInt(roles.length));
      store.state.db.upsertPlayer(player.copyWith(role: role), store.state.room.id);
    }
  }

  Future<String> _createFirstHeist(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    String roomId = store.state.room.id;
    if (store.state.heists.isEmpty && !(await db.heistExists(roomId, 1))) {
      Heist heist = new Heist(price: 12, numPlayers: 2, order: 1);
      return db.upsertHeist(heist, roomId);
    }
    return store.state.heists[0].id;
  }

  Future<void> _createFirstRound(Store<GameModel> store, String heistId) async {
    FirestoreDb db = store.state.db;
    String roomId = store.state.room.id;
    if (!hasRounds(store.state) && !(await db.roundExists(roomId, heistId, 1))) {
      Round round = new Round(order: 1);
      return db.upsertRound(round, roomId, heistId);
    }
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    _assignRoles(store);
    String heistId = await _createFirstHeist(store);
    await _createFirstRound(store, heistId);

    _reloadSubscriptions(store);
  }
}

class LoadGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    await loadGame(store);
    _addGameSetUpListener(store);
  }

  void _completeRequest(Store<GameModel> store, Request request) {
    if (requestInProcess(store.state, request)) {
      store.dispatch(new RequestCompleteAction(request));
    }
  }

  void _clearSetUpRequests(Store<GameModel> store) {
    _completeRequest(store, Request.CreatingNewRoom);
    _completeRequest(store, Request.JoiningGame);
  }

  void _setUpGame(Store<GameModel> store, GameModel gameModel) {
    if (!roomIsAvailable(gameModel)) {
      return;
    }

    if (waitingForPlayers(gameModel)) {
      if (!haveJoinedGame(gameModel) && !requestInProcess(gameModel, Request.JoiningGame)) {
        store.dispatch(new StartRequestAction(Request.JoiningGame));
        store.dispatch(new JoinGameAction());
      }
      return;
    }

    if (isNewGame(gameModel)) {
      if (amOwner(gameModel) && !requestInProcess(gameModel, Request.CreatingNewRoom)) {
        store.dispatch(new StartRequestAction(Request.CreatingNewRoom));
        store.dispatch(new SetUpNewGameAction());
      }
      return;
    }
  }

  void _addGameSetUpListener(Store<GameModel> store) {
    store.onChange.takeWhile((gameModel) => !gameIsReady(gameModel)).listen(
            (gameModel) => _setUpGame(store, gameModel),
        onDone: () => _clearSetUpRequests(store),
        onError: (e) => _clearSetUpRequests(store));
  }

  Future<void> loadGame(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    String roomId = store.state.room.id ?? (await db.getRoomByCode(store.state.room.code)).id;
    List<Heist> heists = await db.getHeists(roomId);
    _subscribe(store, roomId, heists);
  }

  StreamSubscription<Room> _roomSubscription(Store<GameModel> store, String id) {
    return store.state.db.listenOnRoom(id, (room) {
      store.dispatch(new UpdateStateAction<Room>(room));
    });
  }

  StreamSubscription<List<Player>> _playerSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnPlayers(
        roomId, (players) => store.dispatch(new UpdateStateAction<List<Player>>(players)));
  }

  StreamSubscription<List<Heist>> _heistSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnHeists(
        roomId, (heists) => store.dispatch(new UpdateStateAction<List<Heist>>(heists)));
  }

  List<StreamSubscription<List<Round>>> _roundSubscriptions(
      Store<GameModel> store, String roomId, List<Heist> heists) {
    return new List.generate(heists.length, (i) {
      String heistRef = heists[i].id;
      return store.state.db.listenOnRounds(
          roomId,
          heistRef,
              (rounds) =>
              store.dispatch(new UpdateMapEntryAction<String, List<Round>>(heistRef, rounds)));
    });
  }

  void _subscribe(Store<GameModel> store, String roomId, List<Heist> heists) {
    assert(roomId != null);

    List<StreamSubscription> subs = [
      _roomSubscription(store, roomId),
      _playerSubscription(store, roomId),
      _heistSubscription(store, roomId)
    ];

    if (heists != null && heists.isNotEmpty) {
      subs += _roundSubscriptions(store, roomId, heists);
    }

    Subscriptions subscriptions = new Subscriptions(subs: subs);
    store.dispatch(new AddSubscriptionsAction(subscriptions));
  }
}