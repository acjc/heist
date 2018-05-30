part of heist;

@immutable
class GameModel {
  final FirestoreDb db;
  final Subscriptions subscriptions;

  /// Predicate to stop the client kicking off the same async task multiple times.
  /// We may require more specific predicates in future but I've added only a generic one for now.
  final bool busy;

  final Room room;
  final Set<Player> players;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  final int currentBalance;

  GameModel(
      {this.db,
      this.subscriptions,
      this.busy,
      this.room,
      this.players,
      this.heists,
      this.rounds,
      this.currentBalance});

  GameModel copyWith(
      {Subscriptions subscriptions,
      bool busy,
      Room room,
      Set<Player> players,
      List<Heist> heists,
      Map<String, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      busy: busy ?? this.busy,
      room: room ?? this.room,
      players: players ?? this.players,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) => GameModel(
      db: db,
      busy: false,
      room: new Room(numPlayers: numPlayers),
      players: new Set(),
      heists: [],
      rounds: {},
      currentBalance: 0);

  Player me() {
    return players.firstWhere((p) => p.installId == installId());
  }

  bool amOwner() {
    return room.owner == installId();
  }

  Heist currentHeist() {
    return heists.last;
  }

  Round currentRound() {
    return rounds[currentHeist().id].last;
  }

  bool waitingForPlayers() {
    return players.length < room.numPlayers;
  }

  /// A game is new if roles have not yet been assigned.
  bool isNewGame() {
    return players.any((p) => p.role?.isEmpty);
  }

  /// Check various things to see if a game has loaded yet.
  bool isLoading() {
    return room.id == null || players.length <= 1;
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
