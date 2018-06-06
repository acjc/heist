import 'dart:async';

import 'package:heist/main.dart';
import 'package:uuid/uuid.dart';

class MockFirestoreDb implements FirestoreDb {
  Room room;
  Set<Player> players;
  List<Heist> heists;
  Map<String, List<Round>> rounds;

  StreamController<Room> _roomStream;
  StreamController<Set<Player>> _playerStream;
  StreamController<List<Heist>> _heistStream;
  Map<String, StreamController<List<Round>>> _roundStreams = new Map();

  MockFirestoreDb({this.room, this.players, this.heists, this.rounds});

  MockFirestoreDb.empty()
      : this.players = new Set(),
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
  Future<bool> heistExists(String roomId, int order) {
    return new Future<bool>.value(false);
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

  void _postRounds(String heistId) {
    if (_roundStreams != null && rounds != null) {
      // ignore: close_sinks
      StreamController<List<Round>> roundStream = _roundStreams[heistId];
      if (roundStream != null && !roundStream.isClosed) {
        roundStream.add(rounds[heistId]);
      }
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
  StreamSubscription<Set<Player>> listenOnPlayers(
      String roomRef, void onData(Set<Player> players)) {
    _playerStream = new StreamController(onCancel: () => _playerStream.close(), sync: true);
    StreamSubscription<Set<Player>> subscription = _playerStream.stream.listen(onData);
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
  StreamSubscription<List<Round>> listenOnRounds(
      String roomId, String heistId, void onData(List<Round> rounds)) {
    _roundStreams[heistId] =
        new StreamController(onCancel: () => _roundStreams[heistId].close(), sync: true);
    StreamSubscription<List<Round>> subscription = _roundStreams[heistId].stream.listen(onData);
    _postRounds(heistId);
    return subscription;
  }

  @override
  Future<void> upsertPlayer(Player player, String roomId) {
    return new Future<void>(() {
      if (player.id == null) {
        player = player.copyWith(id: new Uuid().v4());
      }
      players
        ..remove(player)
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
        ..remove(heist)
        ..add(heist);
      _postHeists();
      return heist.id;
    });
  }

  @override
  Future<void> upsertRound(Round round, String roomId, String heistId) {
    return new Future<void>(() {
      if (round.id == null) {
        round = round.copyWith(id: new Uuid().v4());
      }
      if (rounds.containsKey(heistId)) {
        rounds[heistId]
          ..remove(round)
          ..add(round);
      } else {
        rounds[heistId] = [round];
      }
      _postRounds(heistId);
    });
  }
}
