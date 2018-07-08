import 'dart:async';

import 'package:heist/main.dart';
import 'package:uuid/uuid.dart';

class MockFirestoreDb implements FirestoreDb {
  Room room;
  List<Player> players;
  List<Heist> heists;
  Map<String, List<Round>> rounds;

  StreamController<Room> _roomStream;
  StreamController<List<Player>> _playerStream;
  StreamController<List<Heist>> _heistStream;
  StreamController<List<Round>> _roundStream;

  MockFirestoreDb({this.room, this.players, this.heists, this.rounds});

  MockFirestoreDb.empty()
      : this.players = [],
        this.heists = [],
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
  Future<List<Heist>> getHeists(String roomRef) {
    return new Future<List<Heist>>.value(heists);
  }

  @override
  Future<bool> roomExistsWithCode(String code) {
    return new Future<bool>.value(false);
  }

  @override
  Future<Heist> getHeist(String roomId, int order) {
    return new Future<Heist>.value(heists.singleWhere((h) => h.order == order, orElse: () => null));
  }

  @override
  Future<bool> roundExists(String roomId, String heistId, int order) {
    return new Future<bool>.value(false);
  }

  @override
  Future<bool> playerExists(String roomId, String installId) {
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

  void _postHeists() {
    if (_heistStream != null && !_heistStream.isClosed && heists != null) {
      _heistStream.add(heists);
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
  StreamSubscription<List<Heist>> listenOnHeists(String roomRef, void onData(List<Heist> heists)) {
    _heistStream = new StreamController(onCancel: () => _heistStream.close(), sync: true);
    StreamSubscription<List<Heist>> subscription = _heistStream.stream.listen(onData);
    _postHeists();
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
        ..add(player);
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
  Future<String> upsertHeist(Heist heist, String roomId) {
    return new Future<String>(() {
      if (heist.id == null) {
        heist = heist.copyWith(id: new Uuid().v4());
      }
      heists
        ..removeWhere((h) => h.id == heist.id)
        ..add(heist);
      _postHeists();
      return heist.id;
    });
  }

  @override
  Future<void> upsertRound(Round round, String roomId) {
    return new Future<void>(() {
      if (round.id == null) {
        round = round.copyWith(id: new Uuid().v4());
      }
      if (rounds.containsKey(round.heist)) {
        rounds[round.heist]
          ..removeWhere((r) => r.id == round.id)
          ..add(round);
      } else {
        rounds[round.heist] = [round];
      }
      _postRounds();
    });
  }

  Round _getRound(String roundId) {
    return rounds.values.expand((rs) => rs).singleWhere((r) => r.id == roundId);
  }

  @override
  Future<void> submitBid(String roundId, String myPlayerId, Bid bid) async {
    Round round = _getRound(roundId);
    Map<String, Bid> bids = new Map.from(round.bids);
    bids[myPlayerId] = bid;
    await upsertRound(round.copyWith(bids: bids), null);
  }

  @override
  Future<void> cancelBid(String roundId, String myPlayerId) {
    return submitBid(roundId, myPlayerId, null);
  }

  @override
  Future<void> updateTeam(String roundId, String playerId, bool inTeam) {
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
  Future<void> submitTeam(String roundId) {
    Round round = _getRound(roundId);
    return upsertRound(round.copyWith(teamSubmitted: true), null);
  }

  Heist _getHeist(String id) {
    return heists.singleWhere((h) => h.id == id);
  }

  @override
  Future<void> makeDecision(String heistId, String playerId, String decision) {
    Heist heist = _getHeist(heistId);
    Map<String, String> decisions = new Map.from(heist.decisions);
    decisions[playerId] = decision;
    return upsertHeist(heist.copyWith(decisions: decisions), null);
  }

  @override
  Future<void> completeRound(String id) {
    Round round = _getRound(id);
    return upsertRound(round.copyWith(completed: true, completedAt: now()), null);
  }

  @override
  Future<void> updatePot(String heistId, int pot) {
    Heist heist = _getHeist(heistId);
    return upsertHeist(heist.copyWith(pot: pot), null);
  }

  @override
  Future<void> completeHeist(String id) {
    Heist heist = _getHeist(id);
    return upsertHeist(heist.copyWith(completed: true, completedAt: now()), null);
  }
}
