part of heist;

class CreateRoomAction extends MiddlewareAction {
  // TODO: get the right roles
  static Set<String> roles = new Set.from(['ACCOUNTANT', 'KINGPIN', 'LEAD_AGENT']);

  @override
  void handle(Store<GameModel> store, action, NextDispatcher next) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      createRoom(new Room(
              appVersion: packageInfo.version,
              code: _generateRoomCode(),
              createdAt: new DateTime.now(),
              numPlayers: store.state.room.numPlayers,
              roles: roles))
          .then((v) => store.dispatch(new EnterRoomAction()));
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

class EnterRoomAction extends MiddlewareAction {
  @override
  void handle(Store<GameModel> store, action, NextDispatcher next) {
    loadGame(store);
    navigatorKey.currentState
        .push(new MaterialPageRoute(builder: (context) => new Game()));
  }

  Future<void> loadGame(Store<GameModel> store) async {
    DocumentSnapshot roomSnapshot = (await getRoom(store.state.room.code)).documents[0];
    Room room = new Room.fromJson(roomSnapshot.documentID, roomSnapshot.data);
    store.dispatch(new UpdateStateAction<Room>(room));

    DocumentSnapshot playerSnapshot = (await getPlayer('test_install_id', room.id)).documents[0];
    Player player = new Player.fromJson(playerSnapshot.documentID, playerSnapshot.data);
    store.dispatch(new UpdateStateAction<Player>(player));

    List<DocumentSnapshot> heistSnapshots = (await getHeists(room.id)).documents;
    List<Heist> heists =
        heistSnapshots.map((s) => new Heist.fromJson(s.documentID, s.data)).toList();
    store.dispatch(new UpdateStateAction<List<Heist>>(heists));

    Map<Heist, List<Round>> rounds = new Map();
    for (Heist heist in heists) {
      List<DocumentSnapshot> roundSnapshots = (await getRounds(room.id, heist.id)).documents;
      rounds[heist] = roundSnapshots.map((s) => new Round.fromJson(s.documentID, s.data)).toList();
    }
    store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>(rounds));
  }
}
