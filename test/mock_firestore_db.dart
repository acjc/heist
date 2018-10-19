import 'dart:async';

import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:uuid/uuid.dart';

class MockFirestoreDb implements FirestoreDb {
  Room room;
  List<Player> players;
  List<Haunt> haunts;
  Map<String, List<Round>> rounds;

  StreamController<Room> _roomStream;
  StreamController<List<Player>> _playerStream;
  StreamController<List<Haunt>> _hauntStream;
  StreamController<List<Round>> _roundStream;

  MockFirestoreDb({this.room, this.players, this.haunts, this.rounds});

  MockFirestoreDb.empty()
      : this.players = [],
        this.haunts = [],
        this.rounds = {};

  @override
  Future<Room> getRoom(String id) {
    return new Future<Room>.value(room);
  }

  @override
  Future<Room> getRoomByCode(String code) {
    return new Future<Room>.value(room);
  }

  @override
  Future<List<Haunt>> getHaunts(String roomRef) {
    return new Future<List<Haunt>>.value(haunts);
  }

  @override
  Future<bool> roomExistsWithCode(String code) {
    return new Future<bool>.value(false);
  }

  @override
  Future<Haunt> getHaunt(String roomId, int order) {
    return new Future<Haunt>.value(haunts.singleWhere((h) => h.order == order, orElse: () => null));
  }

  @override
  Future<bool> roundExists(String roomId, String heistId, int order) {
    return new Future<bool>.value(false);
  }

  @override
  Future<int> getNumPlayers(String roomId) {
    return new Future<int>.value(players.length);
  }

  @override
  Future<bool> playerExists(String roomId, String installId) {
    return new Future<bool>.value(false);
  }

  @override
  Future<bool> playerExistsWithName(String roomId, String name) {
    return new Future<bool>.value(false);
  }

  void _postRoom() {
    if (_roomStream != null && !_roomStream.isClosed && room != null) {
      _roomStream.add(room);
    }
  }

  void _postPlayers() {
    if (_playerStream != null && !_playerStream.isClosed && players != null) {
      _playerStream.add(players);
    }
  }

  void _postHaunts() {
    if (_hauntStream != null && !_hauntStream.isClosed && haunts != null) {
      _hauntStream.add(haunts);
    }
  }

  void _postRounds() {
    if (_roundStream != null && !_roundStream.isClosed && rounds != null) {
      _roundStream.add(rounds.values.expand((rs) => rs).toList());
    }
  }

  @override
  StreamSubscription<Room> listenOnRoom(String code, void Function(Room room) onData) {
    _roomStream = new StreamController(onCancel: () => _roomStream.close(), sync: true);
    StreamSubscription<Room> subscription = _roomStream.stream.listen(onData);
    _postRoom();
    return subscription;
  }

  @override
  StreamSubscription<List<Player>> listenOnPlayers(
      String roomRef, void onData(List<Player> players)) {
    _playerStream = new StreamController(onCancel: () => _playerStream.close(), sync: true);
    StreamSubscription<List<Player>> subscription = _playerStream.stream.listen(onData);
    _postPlayers();
    return subscription;
  }

  @override
  StreamSubscription<List<Haunt>> listenOnHaunts(String roomRef, void onData(List<Haunt> heists)) {
    _hauntStream = new StreamController(onCancel: () => _hauntStream.close(), sync: true);
    StreamSubscription<List<Haunt>> subscription = _hauntStream.stream.listen(onData);
    _postHaunts();
    return subscription;
  }

  @override
  StreamSubscription<List<Round>> listenOnRounds(String roomId, void onData(List<Round> rounds)) {
    _roundStream = new StreamController(onCancel: () => _roundStream.close(), sync: true);
    StreamSubscription<List<Round>> subscription = _roundStream.stream.listen(onData);
    _postRounds();
    return subscription;
  }

  @override
  Future<void> upsertPlayer(Player player, String roomId) {
    return new Future<void>(() {
      if (player.id == null) {
        player = player.copyWith(id: new Uuid().v4());
      }
      players
        ..removeWhere((p) => p.id == player.id)
        ..add(player)
        ..sort((p1, p2) {
          if (p1.order == null) {
            return -1;
          }
          if (p2.order == null) {
            return 1;
          }
          return p1.order.compareTo(p2.order);
        });
      _postPlayers();
    });
  }

  @override
  Future<String> upsertRoom(Room room) {
    return new Future<String>(() {
      if (room.id == null) {
        room = room.copyWith(id: new Uuid().v4());
      }
      this.room = room;
      _postRoom();
      return room.id;
    });
  }

  @override
  Future<String> upsertHaunt(Haunt haunt, String roomId) {
    return new Future<String>(() {
      if (haunt.id == null) {
        haunt = haunt.copyWith(id: new Uuid().v4());
      }
      haunts
        ..removeWhere((h) => h.id == haunt.id)
        ..add(haunt)
        ..sort((h1, h2) => h1.order.compareTo(h2.order));
      _postHaunts();
      return haunt.id;
    });
  }

  @override
  Future<void> upsertRound(Round round, String roomId) {
    return new Future<void>(() {
      if (round.id == null) {
        round = round.copyWith(id: new Uuid().v4());
      }
      if (rounds.containsKey(round.haunt)) {
        rounds[round.haunt]
          ..removeWhere((r) => r.id == round.id)
          ..add(round)
          ..sort((r1, r2) => r1.order.compareTo(r2.order));
      } else {
        rounds[round.haunt] = [round];
      }
      _postRounds();
    });
  }

  Round _getRound(String roundId) {
    return rounds.values.expand((rs) => rs).singleWhere((r) => r.id == roundId);
  }

  @override
  Future<void> submitBid(String roundId, String myPlayerId, Bid bid) {
    Round round = _getRound(roundId);
    Map<String, Bid> bids = new Map.from(round.bids);
    bids[myPlayerId] = bid;
    return upsertRound(round.copyWith(bids: bids), null);
  }

  @override
  Future<void> cancelBid(String roundId, String myPlayerId) {
    return submitBid(roundId, myPlayerId, null);
  }

  @override
  Future<void> sendGift(String roundId, String myPlayerId, Gift gift) {
    Round round = _getRound(roundId);
    Map<String, Gift> gifts = new Map.from(round.gifts);
    gifts[myPlayerId] = gift;
    return upsertRound(round.copyWith(gifts: gifts), null);
  }

  @override
  Future<void> updateExclusions(String roundId, String playerId, bool inTeam) {
    Round round = _getRound(roundId);
    Set<String> team = new Set.of(round.team ?? []);
    if (inTeam) {
      team.add(playerId);
    } else {
      team.remove(playerId);
    }
    return upsertRound(round.copyWith(team: team), null);
  }

  @override
  Future<void> submitExclusions(String roundId) {
    Round round = _getRound(roundId);
    return upsertRound(round.copyWith(exclusionsSubmitted: true), null);
  }

  Haunt _getHaunt(String id) {
    return haunts.singleWhere((h) => h.id == id);
  }

  @override
  Future<void> makeDecision(String hauntId, String playerId, String decision) {
    Haunt haunt = _getHaunt(hauntId);
    Map<String, String> decisions = new Map.from(haunt.decisions);
    decisions[playerId] = decision;
    return upsertHaunt(haunt.copyWith(decisions: decisions), null);
  }

  @override
  Future<void> completeRound(String id) {
    Round round = _getRound(id);
    return upsertRound(round.copyWith(completedAt: now()), null);
  }

  @override
  Future<void> completeHaunt(String id) {
    Haunt haunt = _getHaunt(id);
    return upsertHaunt(haunt.copyWith(completedAt: now()), null);
  }

  @override
  Future<void> completeGame(String id) {
    return upsertRoom(room.copyWith(completedAt: now()));
  }

  @override
  Future<void> addVisibleToAccountant(String id, String playerId) {
    final Set<String> visibleToAccountant =
        room.visibleToAccountant != null ? room.visibleToAccountant : new Set();
    visibleToAccountant.add(playerId);
    return upsertRoom(room.copyWith(visibleToAccountant: visibleToAccountant));
  }

  @override
  Future<void> guessBrenda(String id, String playerId) {
    return upsertRoom(room.copyWith(brendaGuess: playerId));
  }

  @override
  Future<void> updateRole(String id, String roleId, bool selected) {
    Set<String> roles = Set.of(room.roles);
    if (selected) {
      roles.add(roleId);
    } else {
      roles.remove(roleId);
    }
    return upsertRoom(room.copyWith(roles: roles));
  }

  @override
  Future<void> submitRoles(String id) {
    return upsertRoom(room.copyWith(rolesSubmitted: true));
  }
}
