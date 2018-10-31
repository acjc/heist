import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';

class FirestoreDb {
  static final String _rooms = 'rooms';
  static final String _players = 'players';
  // TODO: update to haunts
  static final String _haunts = 'heists';
  static final String _rounds = 'rounds';

  final Firestore _firestore;

  FirestoreDb(this._firestore);

  DocumentReference _roomRef(String id) {
    return _firestore.collection(_rooms).document(id);
  }

  DocumentReference _playerRef(String id) {
    return _firestore.collection(_players).document(id);
  }

  DocumentReference _hauntRef(String id) {
    return _firestore.collection(_haunts).document(id);
  }

  DocumentReference _roundRef(String id) {
    return _firestore.collection(_rounds).document(id);
  }

  Future<Room> getRoom(String id) async => Room.fromSnapshot(await _roomRef(id).get());

  Future<Room> getRoomByCode(String code) async {
    assert(code.length == 4);
    Query query = _firestore.collection(_rooms).where('code', isEqualTo: code);
    if (!isDebugMode()) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: now().add(new Duration(days: -1)));
    }
    QuerySnapshot snapshot = await query.getDocuments();
    if (snapshot.documents.isNotEmpty) {
      return new Room.fromSnapshot(snapshot.documents.first);
    }
    return null;
  }

  Future<bool> roomExistsWithCode(String code) async => await getRoomByCode(code) != null;

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

  StreamSubscription<Room> listenOnRoom(String id, void onData(Room room)) =>
      _roomRef(id).snapshots().map((snapshot) => Room.fromSnapshot(snapshot)).listen(onData);

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

  Query _playerQuery(String roomId) =>
      _firestore.collection(_players).where('room', isEqualTo: _roomRef(roomId));

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

  Query _hauntQuery(String roomId) =>
      _firestore.collection(_haunts).where('room', isEqualTo: _roomRef(roomId));

  StreamSubscription<List<Round>> listenOnRounds(String roomId, void onData(List<Round> rounds)) {
    return _roundQuery(roomId).snapshots().map((snapshot) {
      return snapshot.documents.map((s) => new Round.fromSnapshot(s)).toList();
    }).listen(onData);
  }

  Query _roundQuery(String roomId) =>
      _firestore.collection(_rounds).where('room', isEqualTo: _roomRef(roomId));

  Future<String> upsertRoom(Room room) async {
    DocumentReference roomRef = _roomRef(room.id);
    await roomRef.setData(room.toJson());
    return roomRef.documentID;
  }

  Future<String> upsertHaunt(Haunt haunt, String roomId) async {
    if (haunt.room == null) {
      haunt = haunt.copyWith(room: _roomRef(roomId));
    }
    DocumentReference hauntRef = _hauntRef(haunt.id);
    await hauntRef.setData(haunt.toJson());
    return hauntRef.documentID;
  }

  Future<void> upsertRound(Round round, String roomId) {
    if (round.room == null) {
      round = round.copyWith(room: _roomRef(roomId));
    }
    return _roundRef(round.id).setData(round.toJson());
  }

  Future<void> upsertPlayer(Player player, String roomId) {
    if (player.room == null) {
      player = player.copyWith(room: _roomRef(roomId));
    }
    return _playerRef(player.id).setData(player.toJson());
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

  Future<void> updateTeam(String roundId, int playersRequired, String playerId, bool putInTeam) =>
      _runTransaction((transaction) async {
        DocumentReference roundRef = _roundRef(roundId);
        DocumentSnapshot snapshot = await transaction.get(roundRef);
        Round round = Round.fromSnapshot(snapshot);
        if (!round.teamSubmitted &&
            ((putInTeam && round.team.length < playersRequired) || !putInTeam)) {
          // Make sure to not overwrite other entries in the map
          snapshot.data['team'][playerId] = putInTeam;
          return transaction.update(roundRef, snapshot.data);
        }
      });

  Future<void> submitTeam(String roundId, Set<String> team) => _runTransaction((transaction) async {
        DocumentReference roundRef = _roundRef(roundId);
        Round round = Round.fromSnapshot(await transaction.get(roundRef));
        if (round.team == team) {
          Map<String, dynamic> data = {'teamSubmitted': true};
          return transaction.update(roundRef, data);
        }
      });

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

  Future<void> _runTransaction(TransactionHandler transaction) {
    try {
      return _firestore.runTransaction(transaction);
    } catch (e) {
      debugPrint('Error running transaction: $e');
    }
    return null;
  }

  Future<void> _updateHaunt(String hauntId, Map<String, dynamic> data) =>
      _hauntRef(hauntId).setData(data, merge: true);

  Future<void> _updateRound(String roundId, Map<String, dynamic> data) =>
      _roundRef(roundId).setData(data, merge: true);

  Future<void> _updateRoom(String roomId, Map<String, dynamic> data) =>
      _roomRef(roomId).setData(data, merge: true);
}
