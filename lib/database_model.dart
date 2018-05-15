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
  final String id;
  final String code;
  final DateTime createdAt;
  final String appVersion;
  final bool completed;
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles;

  Room(
      {this.id,
      @required this.code,
      @required this.createdAt,
      @required this.appVersion,
      this.completed = false,
      this.completedAt,
      @required this.numPlayers,
      @required this.roles});

  Room.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        code = json['code'],
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
  final String id;
  final String installId;
  final DocumentReference room;
  final String name;
  final int initialBalance;
  final String role;

  Player(
      {this.id,
      @required this.installId,
      @required this.room,
      @required this.name,
      @required this.initialBalance,
      @required this.role});

  Player.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        installId = json['installId'],
        room = json['room'],
        name = json['name'],
        initialBalance = json['initialBalance'],
        role = json['role'];

  Map<String, dynamic> toJson() => {
        'installId': installId,
        'room': room,
        'name': name,
        'initialBalance': initialBalance,
        'role': role,
      };
}

class Heist {
  final String id;
  final DocumentReference room;
  final int price;
  final int pot;
  final int numPlayers;
  final int order;
  final DateTime startedAt;
  final Map<dynamic, dynamic> decisions; // TODO: change to <String, String>
  // TODO: include Kingpin guesses

  Heist(
      {this.id,
      @required this.room,
      @required this.price,
      @required this.pot,
      @required this.numPlayers,
      @required this.order,
      @required this.startedAt,
      @required this.decisions});

  Heist.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        room = json['room'],
        price = json['price'],
        pot = json['pot'],
        numPlayers = json['numPlayers'],
        order = json['order'],
        startedAt = json['startedAt'],
        decisions = json['decisions'];

  Map<String, dynamic> toJson() => {
        'room': room,
        'price': price,
        'pot': pot,
        'numPlayers': numPlayers,
        'order': order,
        'startedAt': startedAt,
        'decisions': decisions,
      };
}

class Round {
  final String id;
  final DocumentReference leader;
  final int order;
  final DocumentReference room;
  final DocumentReference heist;
  final DateTime startedAt;
  final List<dynamic> team; // TODO: convert to Set<DocumentReference>
  final Map<dynamic, dynamic> bids; // TODO: convert to Map<String, Bid>
  final Map<dynamic, dynamic> gifts; // TODO: convert to Map<String, Gift>

  Round(
      {this.id,
      @required this.leader,
      @required this.order,
      @required this.room,
      @required this.heist,
      @required this.startedAt,
      @required this.team,
      @required this.bids,
      @required this.gifts});

  Round.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        leader = json['leader'],
        order = json['order'],
        room = json['room'],
        heist = json['heist'],
        startedAt = json['startedAt'],
        team = json['team'],
        bids = json['bids'],
        gifts = json['gifts'];

  Map<String, dynamic> toJson() => {
        'leader': leader,
        'order': order,
        'room': room,
        'heist': heist,
        'startedAt': startedAt,
        'team': team,
        'bids': bids,
        'gifts': gifts,
      };
}
