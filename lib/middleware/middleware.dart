part of heist;

List<Middleware<GameModel>> createMiddleware() {
  return [
    new TypedMiddleware<GameModel, CreateRoomAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, LoadGameAction>(_dispatchMiddleware),
    new TypedMiddleware<GameModel, ChangeNumPlayersAction>(_dispatchMiddleware),
  ];
}

/// Delegate middleware intercepts to the MiddlewareActions themselves.
void _dispatchMiddleware(Store<GameModel> store, dynamic action, NextDispatcher next) =>
    action.handle(store, action, next);

/// MiddlewareActions know how to handle themselves.
abstract class MiddlewareAction {
  void handle(Store<GameModel> store, dynamic action, NextDispatcher next);
}

class CreateRoomAction extends MiddlewareAction {
  // TODO: get the right roles
  static Set<String> roles = new Set.from(['ACCOUNTANT', 'KINGPIN', 'LEAD_AGENT']);

  @override
  void handle(Store<GameModel> store, action, NextDispatcher next) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      upsertRoom(new Room(
              appVersion: packageInfo.version,
              code: _generateRoomCode(),
              createdAt: new DateTime.now(),
              numPlayers: store.state.room.numPlayers,
              roles: roles))
          .then((v) => navigatorKey.currentState
              .push(new MaterialPageRoute(builder: (context) => new Game())));
    });
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
  void handle(Store<GameModel> store, action, NextDispatcher next) {
    Room room = store.state.room.copyWith(numPlayers: new Random().nextInt(5) + 5);
    upsertRoom(room);
  }
}

class LoadGameAction extends MiddlewareAction {
  @override
  void handle(Store<GameModel> store, action, NextDispatcher next) {
    _loadGame(store);
  }

  void _loadGame(Store<GameModel> store) async {
    String code = store.state.room.code;
    QuerySnapshot roomSnapshot = (await getRoom(code));
    Room room = new Room.fromSnapshot(roomSnapshot.documents[0]);

    List<DocumentSnapshot> heistSnapshots = (await getHeists(room.id)).documents;
    List<Heist> heists = heistSnapshots.map((s) => new Heist.fromSnapshot(s)).toList();

    _subscribe(store, room, heists);
  }

  StreamSubscription<QuerySnapshot> _roomSubscription(Store<GameModel> store, String code) {
    return listenOnRoom(code, (querySnapshot) {
      Room room = new Room.fromSnapshot(querySnapshot.documents[0]);
      store.dispatch(new UpdateStateAction<Room>(room));
    });
  }

  StreamSubscription<QuerySnapshot> _playerSubscription(Store<GameModel> store, String roomId) {
    return listenOnPlayer('test_install_id', roomId, (querySnapshot) {
      Player player = new Player.fromSnapshot(querySnapshot.documents[0]);
      store.dispatch(new UpdateStateAction<Player>(player));
    });
  }

  StreamSubscription<QuerySnapshot> _heistsSubscription(Store<GameModel> store, String roomId) {
    return listenOnHeists(roomId, (querySnapshot) {
      List<Heist> heists = querySnapshot.documents.map((s) => new Heist.fromSnapshot(s)).toList();
      store.dispatch(new UpdateStateAction<List<Heist>>(heists));
    });
  }

  List<StreamSubscription<QuerySnapshot>> _roundsSubscription(
      Store<GameModel> store, String roomId, List<Heist> heists) {
    return new List.generate(heists.length, (i) {
      String heistRef = heists[i].id;
      return listenOnRounds(roomId, heistRef, (querySnapshot) {
        List<Round> rounds = querySnapshot.documents.map((s) => new Round.fromSnapshot(s)).toList();
        store.dispatch(new UpdateMapEntryAction<String, List<Round>>(heistRef, rounds));
      });
    });
  }

  void _subscribe(Store<GameModel> store, Room room, List<Heist> heists) {
    // ignore: cancel_subscriptions
    StreamSubscription<QuerySnapshot> roomSubscription = _roomSubscription(store, room.code);

    // ignore: cancel_subscriptions
    StreamSubscription<QuerySnapshot> playerSubscription = _playerSubscription(store, room.id);

    // ignore: cancel_subscriptions
    StreamSubscription<QuerySnapshot> heistsSubscription = _heistsSubscription(store, room.id);

    List<StreamSubscription<QuerySnapshot>> roundsSubscriptions =
        _roundsSubscription(store, room.id, heists);

    Subscriptions subscriptions = new Subscriptions(
      subs: [roomSubscription, playerSubscription, heistsSubscription] + roundsSubscriptions,
    );
    store.dispatch(new AddSubscriptionsAction(subscriptions));
  }
}
