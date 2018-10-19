import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';

class FirestoreDb {
  final Firestore _firestore;

  FirestoreDb(this._firestore);

  Future<Room> getRoom(String id) async {
    DocumentSnapshot snapshot = await _firestore.document("rooms/$id").get();
    return new Room.fromSnapshot(snapshot);
  }

  Future<Room> getRoomByCode(String code) async {
    assert(code.length == 4);
    Query query = _firestore.collection('rooms').where('code', isEqualTo: code);
    if (!isDebugMode()) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: now().add(new Duration(days: -1)));
    }
    QuerySnapshot snapshot = await query.getDocuments();
    if (snapshot.documents.isNotEmpty) {
      return new Room.fromSnapshot(snapshot.documents.first);
    }
    return null;
  }

  Future<bool> roomExistsWithCode(String code) async {
    return await getRoomByCode(code) != null;
  }

  Future<int> getNumPlayers(String roomId) async {
    QuerySnapshot snapshot = await _playerQuery(roomId).getDocuments();
    return snapshot.documents.length;
  }

  Future<bool> playerExists(String roomId, String installId) async {
    QuerySnapshot snapshot =
        await _playerQuery(roomId).where('installId', isEqualTo: installId).getDocuments();
    return snapshot.documents.isNotEmpty;
  }

  Future<bool> playerExistsWithName(String roomId, String name) async {
    QuerySnapshot snapshot =
        await _playerQuery(roomId).where('name', isEqualTo: name).getDocuments();
    return snapshot.documents.isNotEmpty;
  }

  Future<Haunt> getHaunt(String roomId, int order) async {
    QuerySnapshot snapshot =
        await _hauntQuery(roomId).where('order', isEqualTo: order).getDocuments();
    return snapshot.documents.isNotEmpty ? new Haunt.fromSnapshot(snapshot.documents.first) : null;
  }

  Future<bool> roundExists(String roomId, String hauntId, int order) async {
    QuerySnapshot snapshot = await _roundQuery(roomId)
        .where('heist', isEqualTo: hauntId)
        .where('order', isEqualTo: order)
        .getDocuments();
    return snapshot.documents.isNotEmpty;
  }

  StreamSubscription<Room> listenOnRoom(String id, void onData(Room room)) {
    return _room(id).snapshots().map((snapshot) => new Room.fromSnapshot(snapshot)).listen(onData);
  }

  DocumentReference _room(String id) {
    return _firestore.document("rooms/$id");
  }

  StreamSubscription<List<Player>> listenOnPlayers(
      String roomRef, void onData(List<Player> players)) {
    return _playerQuery(roomRef).snapshots().map((snapshot) {
      List<Player> players = snapshot.documents.map((s) => new Player.fromSnapshot(s)).toList();
      players.sort((p1, p2) {
        if (p1.order == null) {
          return -1;
        }
        if (p2.order == null) {
          return 1;
        }
        return p1.order.compareTo(p2.order);
      });
      return players;
    }).listen(onData);
  }

  Query _playerQuery(String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    return _firestore.collection('players').where('room', isEqualTo: roomRef);
  }

  Future<List<Haunt>> getHaunts(String roomRef) async {
    QuerySnapshot snapshot = await _hauntQuery(roomRef).getDocuments();
    List<Haunt> haunts = snapshot.documents.map((s) => new Haunt.fromSnapshot(s)).toList();
    haunts.sort((h1, h2) => h1.order.compareTo(h2.order));
    return haunts;
  }

  StreamSubscription<List<Haunt>> listenOnHaunts(String roomRef, void onData(List<Haunt> haunts)) {
    return _hauntQuery(roomRef).snapshots().map((snapshot) {
      List<Haunt> haunts = snapshot.documents.map((s) => new Haunt.fromSnapshot(s)).toList();
      haunts.sort((h1, h2) => h1.order.compareTo(h2.order));
      return haunts;
    }).listen(onData);
  }

  Query _hauntQuery(String roomRef) {
    DocumentReference room = _firestore.document("/rooms/$roomRef");
    return _firestore.collection('heists').where('room', isEqualTo: room);
  }

  StreamSubscription<List<Round>> listenOnRounds(String roomId, void onData(List<Round> rounds)) {
    return _roundQuery(roomId).snapshots().map((snapshot) {
      return snapshot.documents.map((s) => new Round.fromSnapshot(s)).toList();
    }).listen(onData);
  }

  Query _roundQuery(String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    return _firestore.collection('rounds').where('room', isEqualTo: roomRef);
  }

  Future<String> upsertRoom(Room room) async {
    DocumentReference roomRef = _firestore.collection('rooms').document(room.id);
    await roomRef.setData(room.toJson());
    return roomRef.documentID;
  }

  Future<String> upsertHaunt(Haunt haunt, String roomId) async {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    if (haunt.room == null) {
      haunt = haunt.copyWith(room: roomRef);
    }
    DocumentReference hauntRef = _firestore.collection('heists').document(haunt.id);
    await hauntRef.setData(haunt.toJson());
    return hauntRef.documentID;
  }

  Future<void> upsertRound(Round round, String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    if (round.room == null) {
      round = round.copyWith(room: roomRef);
    }
    return _firestore.collection('rounds').document(round.id).setData(round.toJson());
  }

  Future<void> upsertPlayer(Player player, String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    if (player.room == null) {
      player = player.copyWith(room: roomRef);
    }
    return _firestore.collection('players').document(player.id).setData(player.toJson());
  }

  Future<void> submitBid(String roundId, String myPlayerId, Bid bid) {
    Map<String, dynamic> data = {
      'bids': {myPlayerId: bid?.toJson()}
    };
    return _updateRound(roundId, data);
  }

  Future<void> cancelBid(String roundId, String myPlayerId) {
    return submitBid(roundId, myPlayerId, null);
  }

  Future<void> sendGift(String roundId, String myPlayerId, Gift gift) {
    Map<String, dynamic> data = {
      'gifts': {myPlayerId: gift.toJson()}
    };
    return _updateRound(roundId, data);
  }

  Future<void> updateExclusions(String roundId, String playerId, bool excluded) {
    Map<String, dynamic> data = {
      'team': {playerId: excluded}
    };
    return _updateRound(roundId, data);
  }

  Future<void> submitExclusions(String roundId) {
    Map<String, dynamic> data = {'teamSubmitted': true};
    return _updateRound(roundId, data);
  }

  Future<void> makeDecision(String hauntId, String playerId, String decision) {
    Map<String, dynamic> data = {
      'decisions': {playerId: decision}
    };
    return _updateHaunt(hauntId, data);
  }

  Future<void> completeRound(String id) {
    Map<String, dynamic> data = {
      'completedAt': now(),
    };
    return _updateRound(id, data);
  }

  Future<void> completeHaunt(String id) {
    Map<String, dynamic> data = {
      'completedAt': now(),
    };
    return _updateHaunt(id, data);
  }

  Future<void> completeGame(String id) {
    Map<String, dynamic> data = {
      'completedAt': now(),
    };
    return _updateRoom(id, data);
  }

  Future<void> addVisibleToAccountant(String id, String playerId) {
    Map<String, dynamic> data = {
      'visibleToAccountant': {playerId: true},
    };
    return _updateRoom(id, data);
  }

  Future<void> guessBrenda(String id, String playerId) {
    Map<String, dynamic> data = {
      'kingpinGuess': playerId,
    };
    return _updateRoom(id, data);
  }

  Future<void> updateRole(String id, String roleId, bool selected) {
    Map<String, dynamic> data = {
      'roles': {roleId: selected},
    };
    return _updateRoom(id, data);
  }

  Future<void> submitRoles(String id) {
    Map<String, dynamic> data = {
      'rolesSubmitted': true,
    };
    return _updateRoom(id, data);
  }

  Future<void> _updateHaunt(String hauntId, Map<String, dynamic> data) {
    return _firestore.collection('heists').document(hauntId).setData(data, merge: true);
  }

  Future<void> _updateRound(String roundId, Map<String, dynamic> data) {
    return _firestore.collection('rounds').document(roundId).setData(data, merge: true);
  }

  Future<void> _updateRoom(String roomId, Map<String, dynamic> data) {
    return _firestore.collection('rooms').document(roomId).setData(data, merge: true);
  }
}
