part of heist;

List<Middleware<GameModel>> createMiddleware() {
  List<Middleware<GameModel>> middleware = [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, SetUpNewGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, JoinGameAction>(_dispatchMiddleware),
  ];

  // asserts only work in debug mode
  assert(() {
    middleware.add(new LoggingMiddleware.printer());
    return true;
  }());

  return middleware;
}

/// Delegate middleware intercepts to the MiddlewareActions themselves.
void _dispatchMiddleware(Store<GameModel> store, dynamic action, NextDispatcher next) =>
    action.handle(store, action, next);

/// MiddlewareActions know how to handle themselves.
abstract class MiddlewareAction {
  Future<void> handle(Store<GameModel> store, dynamic action, NextDispatcher next);
}

void _reloadSubscriptions(Store<GameModel> store) {
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new LoadGameAction());
}

class CreateRoomAction extends MiddlewareAction {
  // TODO: get the right roles
  static final Set<String> roles =
      new Set.from(['ACCOUNTANT', 'KINGPIN', 'THIEF_1', 'LEAD_AGENT', 'AGENT_1']);

  Future<String> _createRoom(Store<GameModel> store, String code, String appVersion) {
    return store.state.db.upsertRoom(new Room(
        code: code,
        createdAt: now(),
        appVersion: appVersion,
        owner: installId(),
        numPlayers: store.state.room.numPlayers,
        roles: roles));
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String appVersion = await _getAppVersion();
    String code = await _newRoomCode(store);
    String roomId = await _createRoom(store, code, appVersion);
    store.dispatch(new UpdateStateAction<Room>(store.state.room.copyWith(id: roomId, code: code)));

    NavigatorState navigatorState = navigatorKey.currentState;
    if (navigatorState != null) {
      navigatorState.push(new MaterialPageRoute(builder: (context) => new Game()));
    }
  }

  Future<String> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '<unknown>';
    }
  }

  int _getCapitalLetterOrdinal(Random random) {
    return random.nextInt(26) + 65; // 65 is 'A' in ASCII
  }

  Future<String> _newRoomCode(Store<GameModel> store) async {
    String code = _generateRoomCode();
    while (await store.state.db.roomExists(code)) {
      code = _generateRoomCode();
    }
    return code;
  }

  String _generateRoomCode() {
    Random random = new Random();
    List<int> ordinals =
        new List.generate(4, (i) => _getCapitalLetterOrdinal(random), growable: false);
    return new String.fromCharCodes(ordinals);
  }
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

    if (!store.state.haveJoinedGame() && !(await db.playerExists(roomId, iid))) {
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
      Heist heist = new Heist(price: 12, numPlayers: 2, order: 1, startedAt: now());
      return db.upsertHeist(heist, roomId);
    }
    return store.state.heists[0].id;
  }

  Future<void> _createFirstRound(Store<GameModel> store, String heistId) async {
    FirestoreDb db = store.state.db;
    String roomId = store.state.room.id;
    if (!store.state.hasRounds() && !(await db.roundExists(roomId, heistId, 1))) {
      Round round = new Round(order: 1, startedAt: now());
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
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    _setUpGame(store);
    return _loadGame(store);
  }

  void _completeRequest(Store<GameModel> store, Request request) {
    if (store.state.requestInProcess(request)) {
      store.dispatch(new RequestCompleteAction(request));
    }
  }

  void _clearSetUpRequests(Store<GameModel> store) {
    _completeRequest(store, Request.CreatingNewRoom);
    _completeRequest(store, Request.JoiningGame);
  }

  StreamSubscription<GameModel> _setUpGame(Store<GameModel> store) {
    return store.onChange.takeWhile((gameModel) => !gameModel.ready()).listen((gameModel) {
      if (!gameModel.roomIsAvailable()) {
        return;
      }

      if (gameModel.waitingForPlayers()) {
        if (!gameModel.haveJoinedGame() && !gameModel.requestInProcess(Request.JoiningGame)) {
          store.dispatch(new StartRequestAction(Request.JoiningGame));
          store.dispatch(new JoinGameAction());
        }
        return;
      }

      if (gameModel.isNewGame()) {
        if (gameModel.amOwner() && !gameModel.requestInProcess(Request.CreatingNewRoom)) {
          store.dispatch(new StartRequestAction(Request.CreatingNewRoom));
          store.dispatch(new SetUpNewGameAction());
        }
        return;
      }
    }, onDone: () => _clearSetUpRequests(store), onError: (e) => _clearSetUpRequests(store));
  }

  Future<void> _loadGame(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    String roomId = store.state.room.id ?? (await db.getRoom(store.state.room.code)).id;
    List<Heist> heists = await db.getHeists(roomId);
    _subscribe(store, roomId, heists);
  }

  StreamSubscription<Room> _roomSubscription(Store<GameModel> store, String id) {
    return store.state.db.listenOnRoom(id, (room) {
      store.dispatch(new UpdateStateAction<Room>(room));
    });
  }

  StreamSubscription<Set<Player>> _playerSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnPlayers(
        roomId, (players) => store.dispatch(new UpdateStateAction<Set<Player>>(players)));
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
