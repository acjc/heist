part of heist;

List<Middleware<GameModel>> createMiddleware() {
  List<Middleware<GameModel>> middleware = [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, ChangeNumPlayersAction>(_dispatchMiddleware),
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
  static Set<String> roles = new Set.from(['ACCOUNTANT', 'KINGPIN', 'LEAD_AGENT']);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String appVersion = await _getAppVersion();
    String code = _generateRoomCode();
    await store.state.db.upsertRoom(new Room(
        appVersion: appVersion,
        code: code,
        createdAt: new DateTime.now(),
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

  String _generateRoomCode() {
    Random random = new Random();
    List<int> ordinals =
        new List.generate(4, (i) => _getCapitalLetterOrdinal(random), growable: false);
    return new String.fromCharCodes(
        ordinals); // TODO: validate codes are unique for currently open rooms
  }
}

// TODO: This is just a proof of concept that the UI can update directly from firestore
class ChangeNumPlayersAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    Room room = store.state.room.copyWith(numPlayers: new Random().nextInt(5) + 5);
    return store.state.db.upsertRoom(room);
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
    return store.state.db
        .listenOnRoom(code, (room) {
          store.dispatch(new UpdateStateAction<Room>(room));
        });
  }

  StreamSubscription<Player> _playerSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnPlayer('test_install_id', roomId,
        (player) => store.dispatch(new UpdateStateAction<Player>(player)));
  }

  StreamSubscription<List<Heist>> _heistsSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnHeists(
        roomId, (heists) => store.dispatch(new UpdateStateAction<List<Heist>>(heists)));
  }

  List<StreamSubscription<List<Round>>> _roundsSubscription(
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

  void _subscribe(Store<GameModel> store, Room room, List<Heist> heists) {
    List<StreamSubscription> subs = new List();

    if (room != null) {
      subs.addAll([
        _roomSubscription(store, room.code),
        _playerSubscription(store, room.id),
        _heistsSubscription(store, room.id)
      ]);
    }

    if (heists != null && heists.isNotEmpty) {
      subs += _roundsSubscription(store, room.id, heists);
    }

    Subscriptions subscriptions = new Subscriptions(subs: subs);
    store.dispatch(new AddSubscriptionsAction(subscriptions));
  }
}
