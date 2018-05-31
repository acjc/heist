import 'dart:async';

import 'package:heist/main.dart';

class MockFirestoreDb implements FirestoreDb {
  GameModel _gameModel = new GameModel();

  StreamController<Room> _roomStream;
  StreamController<Set<Player>> _playerStream;
  StreamController<List<Heist>> _heistStream;
  Map<String, StreamController<List<Round>>> _roundStreams;

  @override
  Future<List<Heist>> getHeists(String roomRef) {
    return new Future<List<Heist>>.value(_gameModel.heists);
  }

  @override
  Future<Set<Player>> getPlayers(String roomRef) {
    return new Future<Set<Player>>.value(_gameModel.players);
  }

  @override
  Future<Room> getRoom(String code) {
    return new Future<Room>.value(_gameModel.room);
  }

  @override
  Future<bool> roomExists(String code) {
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
  Future<List<Round>> getRounds(String roomRef, String heistRef) {
    return new Future<List<Round>>.value(_gameModel.rounds[heistRef]);
  }

  void _postRoom() {
    if (_roomStream != null && !_roomStream.isClosed && _gameModel.room != null) {
      _roomStream.add(_gameModel.room);
    }
  }

  void _postPlayers() {
    if (_playerStream != null && !_playerStream.isClosed && _gameModel.players != null) {
      _playerStream.add(_gameModel.players);
    }
  }

  void _postHeists() {
    if (_heistStream != null && !_heistStream.isClosed && _gameModel.heists != null) {
      _heistStream.add(_gameModel.heists);
    }
  }

  void _postRounds(String heistId) {
    if (_roundStreams != null && _gameModel.rounds != null) {
      // ignore: close_sinks
      StreamController<List<Round>> roundStream = _roundStreams[heistId];
      if (roundStream != null && !roundStream.isClosed) {
        roundStream.add(_gameModel.rounds[heistId]);
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
  Future<void> upsertPlayer(Player player) {
    return new Future<void>(() {
      Set<Player> updated = new Set<Player>.from(_gameModel.players)..add(player);
      _gameModel = _gameModel.copyWith(players: updated);
      _postPlayers();
    });
  }

  @override
  Future<void> upsertRoom(Room room) {
    return new Future<void>(() {
      _gameModel = _gameModel.copyWith(room: room);
      _postRoom();
    });
  }

  @override
  Future<void> upsertHeist(Heist heist, String roomId) {
    return new Future<void>(() {
      List<Heist> updated = new List.of(_gameModel.heists)
        ..remove(heist)
        ..add(heist);
      _gameModel = _gameModel.copyWith(heists: updated);
      _postHeists();
    });
  }

  @override
  Future<void> upsertRound(Round round, String roomId, String heistId) {
    return new Future<void>(() {
      Map<String, List<Round>> updated = new Map.of(_gameModel.rounds);
      updated[heistId]
        ..remove(round)
        ..add(round);
      _postRounds(heistId);
      _gameModel = _gameModel.copyWith(rounds: updated);
    });
  }
}
