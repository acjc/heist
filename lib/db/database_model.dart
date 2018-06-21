part of heist;

Set<String> _boolMapToSet(Map<String, bool> boolMap) {
  Set<String> set = new Set();
  if (boolMap != null) {
    boolMap.forEach((key, b) {
      if (b) {
        set.add(key);
      }
    });
  }
  return set;
}

Map<String, bool> _toBoolMap(Iterable<String> it, Set<String> allOptions) {
  Map<String, bool> boolMap = new Map();
  if (it != null) {
    allOptions.forEach((o) => boolMap[o] = it.contains(o));
  }
  return boolMap;
}

@immutable
class Document {
  final String id;

  Document({this.id});
}

@immutable
class Room extends Document {
  final String code;
  final DateTime createdAt;
  final String appVersion;
  final String owner;
  final bool completed;
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles;

  Room(
      {id,
      this.code,
      this.createdAt,
      this.appVersion,
      this.owner,
      this.completed = false,
      this.completedAt,
      @required this.numPlayers,
      @required this.roles})
      : super(id: id);

  factory Room.initial() =>
      Room(numPlayers: minPlayers, roles: getRolesIds(numPlayersToRolesMap[minPlayers]));

  Room copyWith({
    String id,
    String code,
    DateTime createdAt,
    String appVersion,
    String owner,
    bool completed,
    DateTime completedAt,
    int numPlayers,
    Set<String> roles,
  }) {
    return new Room(
      id: id ?? this.id,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      appVersion: appVersion ?? this.appVersion,
      owner: owner ?? this.owner,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      numPlayers: numPlayers ?? this.numPlayers,
      roles: roles ?? this.roles,
    );
  }

  Room.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Room.fromJson(String id, Map<String, dynamic> json)
      : code = json['code'],
        createdAt = json['createdAt'],
        appVersion = json['appVersion'],
        owner = json['owner'],
        completed = json['completed'],
        completedAt = json['completedAt'],
        numPlayers = json['numPlayers'],
        roles = _boolMapToSet(json['roles']?.cast<String, bool>()),
        super(id: id);

  Map<String, dynamic> toJson() => {
        'code': code,
        'createdAt': createdAt,
        'appVersion': appVersion,
        'owner': owner,
        'completed': completed,
        'completedAt': completedAt,
        'numPlayers': numPlayers,
        'roles': _toBoolMap(roles, getRolesIds(allRoles)),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          id == other.id &&
          code == other.code &&
          numPlayers == other.numPlayers &&
          roles == other.roles;

  @override
  int get hashCode => id.hashCode ^ code.hashCode ^ numPlayers.hashCode ^ roles.hashCode;

  @override
  String toString() {
    return 'Room{id: $id, code: $code, createdAt: $createdAt, appVersion: $appVersion, owner: $owner, completed: $completed, completedAt: $completedAt, numPlayers: $numPlayers, roles: $roles}';
  }
}

@immutable
class Player extends Document {
  final String installId;
  final DocumentReference room;
  final String name;
  final int initialBalance;
  final String role;
  final int order;

  Player(
      {id,
      @required this.installId,
      this.room,
      @required this.name,
      this.initialBalance,
      this.role,
      this.order})
      : super(id: id);

  Player copyWith({
    String id,
    String installId,
    DocumentReference room,
    String name,
    int initialBalance,
    String role,
    int order,
  }) {
    return new Player(
      id: id ?? this.id,
      installId: installId ?? this.installId,
      room: room ?? this.room,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      role: role ?? this.role,
      order: order ?? this.order,
    );
  }

  Player.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromJson(snapshot.documentID, snapshot.data);

  Player.fromJson(String id, Map<String, dynamic> json)
      : installId = json['installId'],
        room = json['room'],
        name = json['name'],
        initialBalance = json['initialBalance'],
        role = json['role'],
        order = json['order'],
        super(id: id);

  Map<String, dynamic> toJson() => {
        'installId': installId,
        'room': room,
        'name': name,
        'initialBalance': initialBalance,
        'role': role,
        'order': order,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          id == other.id &&
          installId == other.installId &&
          room == other.room &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ installId.hashCode ^ room.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Player{installId: $installId, room: $room, name: $name, initialBalance: $initialBalance, role: $role, order: $order}';
  }
}

@immutable
class Heist extends Document {
  final DocumentReference room;
  final int price;
  final int pot;
  final int numPlayers;
  final int order;
  final DateTime startedAt;
  final Map<String, String> decisions;
  // TODO: include Kingpin guesses

  Heist(
      {id,
      this.room,
      @required this.price,
      this.pot = -1,
      @required this.numPlayers,
      @required this.order,
      this.decisions = const {}})
      : startedAt = now(),
        super(id: id);

  Heist copyWith({
    String id,
    DocumentReference room,
    int price,
    int pot,
    int numPlayers,
    int order,
    DateTime startedAt,
    Map<String, String> decisions, // player ID -> { SUCCEED, FAIL, STEAL }
  }) {
    return new Heist(
      id: id ?? this.id,
      room: room ?? this.room,
      price: price ?? this.price,
      pot: pot ?? this.pot,
      numPlayers: numPlayers ?? this.numPlayers,
      order: order ?? this.order,
      decisions: decisions ?? this.decisions,
    );
  }

  Heist.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Heist.fromJson(String id, Map<String, dynamic> json)
      : room = json['room'],
        price = json['price'],
        pot = json['pot'],
        numPlayers = json['numPlayers'],
        order = json['order'],
        startedAt = json['startedAt'],
        decisions = json['decisions']?.cast<String, String>() ?? {},
        super(id: id);

  Map<String, dynamic> toJson() => {
        'room': room,
        'price': price,
        'pot': pot,
        'numPlayers': numPlayers,
        'order': order,
        'startedAt': startedAt,
        'decisions': decisions,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Heist &&
          id == other.id &&
          room == other.room &&
          price == other.price &&
          decisions == other.decisions;

  @override
  int get hashCode => id.hashCode ^ room.hashCode ^ price.hashCode ^ decisions.hashCode;

  @override
  String toString() {
    return 'Heist{id: $id, room: $room, price: $price, pot: $pot, numPlayers: $numPlayers, order: $order, startedAt: $startedAt, decisions: $decisions}';
  }
}

@immutable
class Bid {
  final int amount;
  final DateTime timestamp;

  Bid(this.amount) : timestamp = now();

  Bid.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'timestamp': timestamp,
      };

  @override
  String toString() {
    return 'Bid{amount: $amount, timestamp: $timestamp}';
  }
}

@immutable
class Gift {
  final int amount;
  final String recipient;
  final DateTime timestamp;

  Gift({this.amount, this.recipient}) : timestamp = now();

  Gift.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        recipient = json['recipient'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'recipient': recipient,
        'timestamp': timestamp,
      };

  @override
  String toString() {
    return 'Gift{amount: $amount, recipient: $recipient, timestamp: $timestamp}';
  }
}

Map<String, Value> _convertValues<Value>(Map<String, dynamic> map, Value transform(v)) {
  Map<String, Value> bidMap = {};
  if (map != null) {
    map.removeWhere((k, v) => v == null);
    map.forEach((k, v) => bidMap[k] = transform(v));
  }
  return bidMap;
}

@immutable
class Round extends Document {
  final String leader;
  final int order;
  final DocumentReference room;
  final String heist;
  final DateTime startedAt;
  final Set<String> team; // player IDs
  final bool teamSubmitted;
  final Map<String, Bid> bids; // player ID -> Bid
  final Map<String, Gift> gifts; // player ID -> Gift

  Round(
      {id,
      this.leader,
      @required this.order,
      this.room,
      @required this.heist,
      this.team,
      this.teamSubmitted = false,
      this.bids = const {},
      this.gifts = const {}})
      : startedAt = now(),
        super(id: id);

  Round copyWith({
    String id,
    String leader,
    int order,
    DocumentReference room,
    String heist,
    DateTime startedAt,
    Set<String> team,
    bool teamSubmitted,
    Map<String, Bid> bids,
    Map<String, Gift> gifts,
  }) {
    return new Round(
      id: id ?? this.id,
      leader: leader ?? this.leader,
      order: order ?? this.order,
      room: room ?? this.room,
      heist: heist ?? this.heist,
      team: team ?? this.team,
      teamSubmitted: teamSubmitted ?? this.teamSubmitted,
      bids: bids ?? this.bids,
      gifts: gifts ?? this.gifts,
    );
  }

  Round.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Round.fromJson(String id, Map<String, dynamic> json)
      : leader = json['leader'],
        order = json['order'],
        room = json['room'],
        heist = json['heist'],
        startedAt = json['startedAt'],
        team = _boolMapToSet(json['team'].cast<String, bool>()),
        teamSubmitted = json['teamSubmitted'],
        bids = _convertValues(json['bids']?.cast<String, dynamic>(),
            (v) => new Bid.fromJson(v.cast<String, dynamic>())),
        gifts = _convertValues(json['gifts']?.cast<String, dynamic>(),
            (v) => new Gift.fromJson(v.cast<String, dynamic>())),
        super(id: id);

  Map<String, dynamic> toJson() => {
        'leader': leader,
        'order': order,
        'room': room,
        'heist': heist,
        'startedAt': startedAt,
        'team': team,
        'teamSubmitted': teamSubmitted,
        'bids': bids,
        'gifts': gifts,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Round &&
          id == other.id &&
          team == other.team &&
          teamSubmitted == other.teamSubmitted &&
          bids == other.bids &&
          gifts == other.gifts;

  @override
  int get hashCode =>
      id.hashCode ^ team.hashCode ^ teamSubmitted.hashCode ^ bids.hashCode ^ gifts.hashCode;

  @override
  String toString() {
    return 'Round{leader: $leader, order: $order, room: $room, heist: $heist, startedAt: $startedAt, team: $team, teamSubmitted: $teamSubmitted, bids: $bids, gifts: $gifts}';
  }
}
