part of heist;

@immutable
class GameModel {
  final Subscriptions subscriptions;

  final Room room;
  final Player player;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  final int currentBalance;

  GameModel(
      {this.subscriptions, this.room, this.player, this.heists, this.rounds, this.currentBalance});

  GameModel copyWith(
      {Subscriptions subscriptions,
      Room room,
      Player player,
      List<Heist> heists,
      Map<String, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      subscriptions: subscriptions ?? this.subscriptions,
      room: room ?? this.room,
      player: player ?? this.player,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(int numPlayers) => GameModel(room: new Room(numPlayers: numPlayers));
}

@immutable
class Subscriptions {
  final List<StreamSubscription<QuerySnapshot>> subs;

  Subscriptions({this.subs});

  Subscriptions copyWith(List<StreamSubscription<QuerySnapshot>> subs) {
    return new Subscriptions(subs: subs ?? this.subs);
  }
}
