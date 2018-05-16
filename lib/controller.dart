part of heist;

@immutable
class GameModel {
  final Room room;
  final Player player;
  final List<Heist> heists;
  final Map<Heist, List<Round>> rounds;

  final int currentBalance;

  GameModel({this.room, this.player, this.heists, this.rounds, this.currentBalance});

  GameModel copyWith(
      {Room room,
      Player player,
      List<Heist> heists,
      Map<Heist, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      room: room ?? this.room,
      player: player ?? this.player,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(int numPlayers) => GameModel(room: new Room(numPlayers: numPlayers));
}

class Controller {
  final String code;

  GameModel gameModel;

  Controller(this.code);

  Future<GameModel> load() async {
    DocumentSnapshot roomSnapshot = (await getRoom(code)).documents[0];
    Room room = new Room.fromJson(roomSnapshot.documentID, roomSnapshot.data);

    DocumentSnapshot playerSnapshot = (await getPlayer('test_install_id', room.id)).documents[0];
    Player player = new Player.fromJson(playerSnapshot.documentID, playerSnapshot.data);

    List<DocumentSnapshot> heistSnapshots = (await getHeists(room.id)).documents;
    List<Heist> heists =
        heistSnapshots.map((s) => new Heist.fromJson(s.documentID, s.data)).toList();

    Map<Heist, List<Round>> rounds = new Map();
    for (Heist heist in heists) {
      List<DocumentSnapshot> roundSnapshots = (await getRounds(room.id, heist.id)).documents;
      rounds[heist] = roundSnapshots.map((s) => new Round.fromJson(s.documentID, s.data)).toList();
    }

    return new GameModel(room: room, player: player, heists: heists, rounds: rounds);
  }
}
