part of heist;

@immutable
class GameModel {
  final FirestoreDb db;
  final Subscriptions subscriptions;

  final String playerName;

  /// List of pending requests to avoid kicking off the same request multiple times.
  final Set<Request> requests;

  final Room room;
  final Set<Player> players;
  final List<Heist> heists;
  final Map<String, List<Round>> rounds;

  final int currentBalance;

  GameModel(
      {this.db,
      this.subscriptions,
      this.playerName,
      this.requests,
      this.room,
      this.players,
      this.heists,
      this.rounds,
      this.currentBalance});

  GameModel copyWith(
      {Subscriptions subscriptions,
      String playerName,
      Set<Request> requests,
      Room room,
      Set<Player> players,
      List<Heist> heists,
      Map<String, List<Round>> rounds,
      int currentBalance}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      playerName: playerName ?? this.playerName,
      requests: requests ?? this.requests,
      room: room ?? this.room,
      players: players ?? this.players,
      heists: heists ?? this.heists,
      rounds: rounds ?? this.rounds,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) => GameModel(
      db: db,
      playerName: null,
      requests: new Set(),
      room: new Room.initial(),
      players: new Set(),
      heists: [],
      rounds: {},
      currentBalance: 0);

  Player me() {
    return players.firstWhere((p) => p.installId == installId(), orElse: () => null);
  }

  bool haveJoinedGame() {
    Player myself = me();
    return myself != null && myself.room?.documentID == room.id;
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
    return players.any((p) => p.role == null || p.role.isEmpty) || heists.isEmpty || !hasRounds();
  }

  bool hasRounds() {
    return rounds.isNotEmpty && rounds.values.any((rs) => rs.isNotEmpty);
  }

  bool roomIsAvailable() {
    return room.id != null;
  }

  bool ready() {
    return roomIsAvailable() && !isNewGame() && heists.isNotEmpty && hasRounds();
  }

  bool requestInProcess(Request request) {
    return requests.contains(request);
  }

  int getCurrentBalance() {
    return currentBalance;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GameModel &&
              db == other.db &&
              subscriptions == other.subscriptions &&
              playerName == other.playerName &&
              requests == other.requests &&
              room == other.room &&
              players == other.players &&
              heists == other.heists &&
              rounds == other.rounds &&
              currentBalance == other.currentBalance;

  @override
  int get hashCode =>
      db.hashCode ^
      subscriptions.hashCode ^
      playerName.hashCode ^
      requests.hashCode ^
      room.hashCode ^
      players.hashCode ^
      heists.hashCode ^
      rounds.hashCode ^
      currentBalance.hashCode;

  @override
  String toString() {
    return 'GameModel{db: $db, subscriptions: $subscriptions, playerName: $playerName, requests: $requests, room: $room, players: $players, heists: $heists, rounds: $rounds, currentBalance: $currentBalance}';
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

enum Request { CreatingNewRoom, JoiningGame }
