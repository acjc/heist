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
