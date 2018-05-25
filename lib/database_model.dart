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
      this.numPlayers,
      this.roles})
      : super(id: id);

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
        roles = new Set(),
        super(id: id) {
    _boolMapToSet(json['roles'], roles);
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'createdAt': createdAt,
        'appVersion': appVersion,
        'owner': owner,
        'completed': completed,
        'completedAt': completedAt,
        'numPlayers': numPlayers,
        'roles': _setToBoolMap(roles), // TODO: put false for roles not included
      };
}

@immutable
class Player extends Document {
  final String installId;
  final DocumentReference room;
  final String name;
  final int initialBalance;
  final String role;

  Player(
      {id,
      @required this.installId,
      @required this.room,
      @required this.name,
      @required this.initialBalance,
      @required this.role})
      : super(id: id);

  Player copyWith({
    String id,
    String installId,
    DocumentReference room,
    String name,
    int initialBalance,
    String role,
  }) {
    return new Player(
      id: id ?? this.id,
      installId: installId ?? this.installId,
      room: room ?? this.room,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      role: role ?? this.role,
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
        super(id: id);

  Map<String, dynamic> toJson() => {
        'installId': installId,
        'room': room,
        'name': name,
        'initialBalance': initialBalance,
        'role': role,
      };
}

@immutable
class Heist extends Document {
  final DocumentReference room;
  final int price;
  final int pot;
  final int numPlayers;
  final int order;
  final DateTime startedAt;
  final Map<dynamic, dynamic> decisions; // TODO: change to <String, String>
  // TODO: include Kingpin guesses

  Heist(
      {id,
      @required this.room,
      @required this.price,
      @required this.pot,
      @required this.numPlayers,
      @required this.order,
      @required this.startedAt,
      @required this.decisions})
      : super(id: id);

  Heist copyWith({
    String id,
    DocumentReference room,
    int price,
    int pot,
    int numPlayers,
    int order,
    DateTime startedAt,
    Map<dynamic, dynamic> decisions,
  }) {
    return new Heist(
      id: id ?? this.id,
      room: room ?? this.room,
      price: price ?? this.price,
      pot: pot ?? this.pot,
      numPlayers: numPlayers ?? this.numPlayers,
      order: order ?? this.order,
      startedAt: startedAt ?? this.startedAt,
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
        decisions = json['decisions'],
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
}

@immutable
class Round extends Document {
  final DocumentReference leader;
  final int order;
  final DocumentReference room;
  final DocumentReference heist;
  final DateTime startedAt;
  final List<dynamic> team; // TODO: convert to Set<DocumentReference>
  final Map<dynamic, dynamic> bids; // TODO: convert to Map<String, Bid>
  final Map<dynamic, dynamic> gifts; // TODO: convert to Map<String, Gift>

  Round(
      {id,
      @required this.leader,
      @required this.order,
      @required this.room,
      @required this.heist,
      @required this.startedAt,
      @required this.team,
      @required this.bids,
      @required this.gifts})
      : super(id: id);

  Round copyWith({
    String id,
    DocumentReference leader,
    int order,
    DocumentReference room,
    DocumentReference heist,
    DateTime startedAt,
    List<dynamic> team,
    Map<dynamic, dynamic> bids,
    Map<dynamic, dynamic> gifts,
  }) {
    return new Round(
      id: id ?? this.id,
      leader: leader ?? this.leader,
      order: order ?? this.order,
      room: room ?? this.room,
      heist: heist ?? this.heist,
      startedAt: startedAt ?? this.startedAt,
      team: team ?? this.team,
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
        team = json['team'],
        bids = json['bids'],
        gifts = json['gifts'],
        super(id: id);

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
