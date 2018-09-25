import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/main.dart';
import 'package:heist/role.dart';

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
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles;
  final Set<String> visibleToAccountant;
  final String brendaGuess; // player ID

  Room({
    id,
    this.code,
    this.createdAt,
    this.appVersion,
    this.owner,
    this.completedAt,
    @required this.numPlayers,
    @required this.roles,
    this.visibleToAccountant,
    this.brendaGuess,
  }) : super(id: id);

  factory Room.initial(int numPlayers) =>
      Room(numPlayers: numPlayers, roles: Roles.getRoleIds(Roles.numPlayersToRolesMap[numPlayers]));

  Room copyWith({
    String id,
    String code,
    DateTime createdAt,
    String appVersion,
    String owner,
    DateTime completedAt,
    int numPlayers,
    Set<String> roles,
    Set<String> visibleToAccountant,
    String brendaGuess,
  }) {
    return new Room(
      id: id ?? this.id,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      appVersion: appVersion ?? this.appVersion,
      owner: owner ?? this.owner,
      completedAt: completedAt ?? this.completedAt,
      numPlayers: numPlayers ?? this.numPlayers,
      roles: roles ?? this.roles,
      visibleToAccountant: visibleToAccountant ?? this.visibleToAccountant,
      brendaGuess: brendaGuess ?? this.brendaGuess,
    );
  }

  Room.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Room.fromJson(String id, Map<String, dynamic> json)
      : code = json['code'],
        createdAt = json['createdAt'],
        appVersion = json['appVersion'],
        owner = json['owner'],
        completedAt = json['completedAt'],
        numPlayers = json['numPlayers'],
        roles = _boolMapToSet(json['roles']?.cast<String, bool>()),
        visibleToAccountant = _boolMapToSet(json['visibleToAccountant']?.cast<String, bool>()),
        brendaGuess = json['kingpinGuess'],
        super(id: id);

  Map<String, dynamic> toJson() => {
        'code': code,
        'createdAt': createdAt,
        'appVersion': appVersion,
        'owner': owner,
        'completedAt': completedAt,
        'numPlayers': numPlayers,
        'roles': _toBoolMap(roles, Roles.getRoleIds(Roles.allRoles)),
        'visibleToAccountant': _toBoolMap(visibleToAccountant, visibleToAccountant),
        'kingpinGuessed': brendaGuess,
      };

  bool get complete => completedAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          id == other.id &&
          code == other.code &&
          numPlayers == other.numPlayers &&
          roles == other.roles &&
          completedAt == other.completedAt &&
          visibleToAccountant == other.visibleToAccountant &&
          brendaGuess == other.brendaGuess;

  @override
  int get hashCode =>
      id.hashCode ^
      code.hashCode ^
      numPlayers.hashCode ^
      roles.hashCode ^
      completedAt.hashCode ^
      visibleToAccountant.hashCode ^
      brendaGuess.hashCode;

  @override
  String toString() {
    return 'Room{id: $id, code: $code, createdAt: $createdAt, appVersion: $appVersion, owner: $owner, completedAt: $completedAt, numPlayers: $numPlayers, roles: $roles, visibleToAccountant: $visibleToAccountant, brendaGuess: $brendaGuess}';
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
      this.initialBalance = 8, // TODO: initial balance may eventually depend on role
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
    return 'Player{id: $id, installId: $installId, room: $room, name: $name, initialBalance: $initialBalance, role: $role, order: $order}';
  }
}

@immutable
class Haunt extends Document {
  final DocumentReference room;
  final int price;
  final int numPlayers;
  final int maximumBid;
  final int order;
  final DateTime startedAt;
  final Map<String, String> decisions;
  final DateTime completedAt;

  Haunt(
      {id,
      this.room,
      @required this.price,
      @required this.numPlayers,
      @required this.maximumBid,
      @required this.order,
      @required this.startedAt,
      this.decisions = const {},
      this.completedAt})
      : super(id: id);

  Haunt copyWith({
    String id,
    DocumentReference room,
    int price,
    int numPlayers,
    int maximumBid,
    int order,
    DateTime startedAt,
    Map<String, String> decisions, // player ID -> { SUCCEED, FAIL, STEAL }
    DateTime completedAt,
  }) {
    return new Haunt(
      id: id ?? this.id,
      room: room ?? this.room,
      price: price ?? this.price,
      numPlayers: numPlayers ?? this.numPlayers,
      maximumBid: maximumBid ?? this.maximumBid,
      order: order ?? this.order,
      startedAt: startedAt ?? this.startedAt,
      decisions: decisions ?? this.decisions,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Haunt.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Haunt.fromJson(String id, Map<String, dynamic> json)
      : room = json['room'],
        price = json['price'],
        numPlayers = json['numPlayers'],
        maximumBid = json['maximumBid'],
        order = json['order'],
        startedAt = json['startedAt'],
        decisions = json['decisions']?.cast<String, String>() ?? {},
        completedAt = json['completedAt'],
        super(id: id);

  Map<String, dynamic> toJson() => {
        'room': room,
        'price': price,
        'numPlayers': numPlayers,
        'maximumBid': maximumBid,
        'order': order,
        'startedAt': startedAt,
        'decisions': decisions,
        'completedAt': completedAt,
      };

  bool get complete => completedAt != null;

  bool get allDecided => decisions.length == numPlayers;

  bool get wasSuccess {
    List<String> decisions = this.decisions.values.toList();
    assert(decisions.length == numPlayers);
    int steals = decisions.where((d) => d == Steal).length;
    return !decisions.contains(Tickle) && steals < 2;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Haunt &&
          id == other.id &&
          decisions == other.decisions &&
          complete == other.complete;

  @override
  int get hashCode => id.hashCode ^ decisions.hashCode ^ complete.hashCode;

  @override
  String toString() {
    return 'Haunt{id: $id, room: $room, price: $price, numPlayers: $numPlayers, maximumBid: $maximumBid, order: $order, startedAt: $startedAt, decisions: $decisions, completedAt: $completedAt}';
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
  final int order;
  final DocumentReference room;
  final String haunt;
  final DateTime startedAt;
  final Set<String> team; // player IDs
  final bool teamSubmitted;
  final Map<String, Bid> bids; // player ID -> Bid
  final Map<String, Gift> gifts; // player ID -> Gift
  final DateTime completedAt;

  Round(
      {id,
      @required this.order,
      this.room,
      @required this.haunt,
      @required this.startedAt,
      @required this.team,
      this.teamSubmitted = false,
      this.bids = const {},
      this.gifts = const {},
      this.completedAt})
      : super(id: id);

  Round copyWith({
    String id,
    int order,
    DocumentReference room,
    String haunt,
    DateTime startedAt,
    Set<String> team,
    bool teamSubmitted,
    Map<String, Bid> bids,
    Map<String, Gift> gifts,
    DateTime completedAt,
  }) {
    return new Round(
      id: id ?? this.id,
      order: order ?? this.order,
      room: room ?? this.room,
      haunt: haunt ?? this.haunt,
      startedAt: startedAt ?? this.startedAt,
      team: team ?? this.team,
      teamSubmitted: teamSubmitted ?? this.teamSubmitted,
      bids: bids ?? this.bids,
      gifts: gifts ?? this.gifts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Round.fromSnapshot(DocumentSnapshot snapshot) : this.fromJson(snapshot.documentID, snapshot.data);

  Round.fromJson(String id, Map<String, dynamic> json)
      : order = json['order'],
        room = json['room'],
        haunt = json['heist'],
        startedAt = json['startedAt'],
        team = _boolMapToSet(json['team'].cast<String, bool>()),
        teamSubmitted = json['teamSubmitted'],
        bids = _convertValues(json['bids']?.cast<String, dynamic>(),
            (v) => new Bid.fromJson(v.cast<String, dynamic>())),
        gifts = _convertValues(json['gifts']?.cast<String, dynamic>(),
            (v) => new Gift.fromJson(v.cast<String, dynamic>())),
        completedAt = json['completedAt'],
        super(id: id);

  Map<String, dynamic> toJson() => {
        'order': order,
        'room': room,
        'heist': haunt,
        'startedAt': startedAt,
        'team': _toBoolMap(team, team),
        'teamSubmitted': teamSubmitted,
        'bids': bids,
        'gifts': gifts,
        'completedAt': completedAt,
      };

  bool get isAuction => order == 5;

  int get pot => bids.isNotEmpty
      ? bids.values.fold(0, (previousValue, bid) => previousValue + bid.amount)
      : -1;

  bool get complete => completedAt != null;

  bool get wasPlayerLed => complete && !isAuction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Round &&
          id == other.id &&
          team == other.team &&
          teamSubmitted == other.teamSubmitted &&
          bids == other.bids &&
          gifts == other.gifts &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      team.hashCode ^
      teamSubmitted.hashCode ^
      bids.hashCode ^
      gifts.hashCode ^
      completedAt.hashCode;

  @override
  String toString() {
    return 'Round{id: $id, order: $order, room: $room, haunt: $haunt, startedAt: $startedAt, team: $team, teamSubmitted: $teamSubmitted, bids: $bids, gifts: $gifts, completedAt: $completedAt}';
  }
}
