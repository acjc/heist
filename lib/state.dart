part of heist;

@immutable
class GameModel {
  final FirestoreDb db;
  final Subscriptions subscriptions;

  final String playerName;
  final int bidAmount;

  /// List of pending requests to avoid kicking off the same request multiple times.
  final Set<Request> requests;

  final Room room;
  final List<Player> players;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  GameModel(
      {this.db,
      this.subscriptions,
      this.playerName,
      this.bidAmount,
      this.requests,
      this.room,
      this.players,
      this.heists,
      this.rounds});

  GameModel copyWith(
      {Subscriptions subscriptions,
      String playerName,
      int bidAmount,
      Set<Request> requests,
      Room room,
      List<Player> players,
      List<Heist> heists,
      Map<String, List<Round>> rounds}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      playerName: playerName ?? this.playerName,
      bidAmount: bidAmount ?? this.bidAmount,
      requests: requests ?? this.requests,
      room: room ?? this.room,
      players: players ?? this.players,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) => GameModel(
      db: db,
      playerName: null,
      bidAmount: 0,
      requests: new Set(),
      room: new Room.initial(),
      players: [],
      heists: [],
      rounds: {});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModel &&
          db == other.db &&
          subscriptions == other.subscriptions &&
          playerName == other.playerName &&
          bidAmount == other.bidAmount &&
          requests == other.requests &&
          room == other.room &&
          players == other.players &&
          heists == other.heists &&
          rounds == other.rounds;

  @override
  int get hashCode =>
      db.hashCode ^
      subscriptions.hashCode ^
      playerName.hashCode ^
      bidAmount.hashCode ^
      requests.hashCode ^
      room.hashCode ^
      players.hashCode ^
      heists.hashCode ^
      rounds.hashCode;

  @override
  String toString() {
    return 'GameModel{db: $db, subscriptions: $subscriptions, playerName: $playerName, bidAmount: $bidAmount, requests: $requests, room: $room, players: $players, heists: $heists, rounds: $rounds}';
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

enum Request { CreatingNewRoom, JoiningGame, Bidding }
