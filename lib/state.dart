part of heist;

@immutable
class GameModel {
  final FirestoreDb db;

  final Subscriptions subscriptions;

  final Room room;
  final Player player;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  final int currentBalance;

  GameModel(
      {this.db,
      this.subscriptions,
      this.room,
      this.player,
      this.heists,
      this.rounds,
      this.currentBalance});

  GameModel copyWith(
      {Subscriptions subscriptions,
      Room room,
      Player player,
      List<Heist> heists,
      Map<String, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      room: room ?? this.room,
      player: player ?? this.player,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) =>
      GameModel(db: db, room: new Room(numPlayers: numPlayers));
}

@immutable
class Subscriptions {
  final List<StreamSubscription> subs;

  Subscriptions({this.subs});

  Subscriptions copyWith(List<StreamSubscription> subs) {
    return new Subscriptions(subs: subs ?? this.subs);
  }
}
