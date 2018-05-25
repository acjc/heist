part of heist;

@immutable
class GameModel {
  final FirestoreDb db;

  final Subscriptions subscriptions;

  final Room room;
  final Set<Player> players;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  final int currentBalance;

  GameModel(
      {this.db,
      this.subscriptions,
      this.room,
      this.players,
      this.heists,
      this.rounds,
      this.currentBalance});

  GameModel copyWith(
      {Subscriptions subscriptions,
      Room room,
      Set<Player> players,
      List<Heist> heists,
      Map<String, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      room: room ?? this.room,
      players: players ?? this.players,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) =>
      GameModel(db: db, room: new Room(numPlayers: numPlayers));

  Player me() {
    return players.firstWhere((p) => p.installId == installId);
  }
}

@immutable
class Subscriptions {
  final List<StreamSubscription> subs;

  Subscriptions({this.subs});

  Subscriptions copyWith(List<StreamSubscription> subs) {
    return new Subscriptions(subs: subs ?? this.subs);
  }
}
