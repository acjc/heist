part of heist;

List<Middleware<GameModel>> createMiddleware() {
  List<Middleware<GameModel>> middleware = [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
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

class CreateRoomAction extends MiddlewareAction {
  // TODO: get the right roles
  static final Set<String> roles =
      new Set.from(['ACCOUNTANT', 'KINGPIN', 'THIEF_1', 'LEAD_AGENT', 'AGENT_1']);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String appVersion = await _getAppVersion();
    String code = await _newRoomCode(store);

    await store.state.db.upsertRoom(new Room(
        code: code,
        createdAt: new DateTime.now().toUtc(),
        appVersion: appVersion,
        owner: installId(),
        numPlayers: store.state.room.numPlayers,
        roles: roles));

    store.dispatch(new EnterCodeAction(code));

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

class LoadGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return _loadGame(store);
  }

  Future<void> _loadGame(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    String code = store.state.room.code;

    Room room = await db.getRoom(code);
    List<Heist> heists = await db.getHeists(room.id);

    _subscribe(store, room, heists);
  }

  StreamSubscription<Room> _roomSubscription(Store<GameModel> store, String code) {
    return store.state.db.listenOnRoom(code, (room) {
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

  // TODO: We need to subscribe to new rounds as they are created
  void _subscribe(Store<GameModel> store, Room room, List<Heist> heists) {
    assert(room != null);

    List<StreamSubscription> subs = new List();

    subs.addAll([
      _roomSubscription(store, room.code),
      _playerSubscription(store, room.id),
      _heistSubscription(store, room.id)
    ]);

    if (heists != null && heists.isNotEmpty) {
      subs += _roundSubscriptions(store, room.id, heists);
    }

    Subscriptions subscriptions = new Subscriptions(subs: subs);
    store.dispatch(new AddSubscriptionsAction(subscriptions));
  }
}
