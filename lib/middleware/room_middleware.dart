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
