part of heist;

void _boolMapToSet(var boolMap, Set<String> set) {
  boolMap.forEach((key, b) {
    if (b) {
      set.add(key);
    }
  });
}

Map<String, bool> _setToBoolMap(Set<String> set) {
  Map<String, bool> boolMap = new Map();
  set.forEach((r) => boolMap[r] = true);
  return boolMap;
}

class Room {
  final String code;
  final DateTime createdAt;
  final String appVersion;
  final bool completed;
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles;

  Room(
      {@required this.code,
      @required this.createdAt,
      @required this.appVersion,
      this.completed = false,
      this.completedAt,
      @required this.numPlayers,
      @required this.roles});

  Room.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        createdAt = json['createdAt'],
        appVersion = json['appVersion'],
        completed = json['completed'],
        completedAt = json['completedAt'],
        numPlayers = json['numPlayers'],
        roles = new Set() {
    _boolMapToSet(json['roles'], roles);
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'createdAt': createdAt,
        'appVersion': appVersion,
        'completed': completed,
        'completedAt': completedAt,
        'numPlayers': numPlayers,
        'roles': _setToBoolMap(roles), // TODO: put false for roles not included
      };
}

class Player {
  final String installId;
  final String roomRef;
  final String name;
  final int initialBalance;
  final String role;

  Player(
      {@required this.installId,
      @required this.roomRef,
      @required this.name,
      @required this.initialBalance,
      @required this.role});

  Player.fromJson(Map<String, dynamic> json)
      : installId = json['installId'],
        roomRef = json['roomRef'],
        name = json['name'],
        initialBalance = json['initialBalance'],
        role = json['role'];

  Map<String, dynamic> toJson() => {
        'installId': installId,
        'roomRef': roomRef,
        'name': name,
        'initialBalance': initialBalance,
        'role': role,
      };
}

class Heist {
  final String roomRef;
  final int price;
  final int pot;
  final int numPlayers;
  final int order;
  final DateTime startedAt;
  final Map<String, String> decisions;
  // TODO: include Kingpin guesses

  Heist(
      {@required this.roomRef,
      @required this.price,
      @required this.pot,
      @required this.numPlayers,
      @required this.order,
      @required this.startedAt,
      @required this.decisions});

  Heist.fromJson(Map<String, dynamic> json)
      : roomRef = json['roomRef'],
        price = json['price'],
        pot = json['pot'],
        numPlayers = json['numPlayers'],
        order = json['order'],
        startedAt = json['startedAt'],
        decisions = json['decisions'];

  Map<String, dynamic> toJson() => {
        'roomRef': roomRef,
        'price': price,
        'pot': pot,
        'numPlayers': numPlayers,
        'order': order,
        'startedAt': startedAt,
        'decisions': decisions,
      };
}

class Round {
  final String leader;
  final int order;
  final String roomRef;
  final String heistRef;
  final DateTime startedAt;
  final Set<String> team;
  final Map<String, dynamic> bids; // TODO: convert to Map<String, Bid>
  final Map<String, dynamic> gifts; // TODO: convert to Map<String, Gift>

  Round(
      {@required this.leader,
      @required this.order,
      @required this.roomRef,
      @required this.heistRef,
      @required this.startedAt,
      @required this.team,
      @required this.bids,
      @required this.gifts});

  Round.fromJson(Map<String, dynamic> json)
      : leader = json['leader'],
        order = json['order'],
        roomRef = json['roomRef'],
        heistRef = json['heistRef'],
        startedAt = json['startedAt'],
        team = json['team'],
        bids = json['bids'],
        gifts = json['gifts'];

  Map<String, dynamic> toJson() => {
        'leader': leader,
        'order': order,
        'roomRef': roomRef,
        'heistRef': heistRef,
        'startedAt': startedAt,
        'team': team,
        'bids': bids,
        'gifts': gifts,
      };
}
