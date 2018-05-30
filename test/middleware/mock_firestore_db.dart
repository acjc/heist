import 'dart:async';

import 'package:heist/main.dart';

class MockFirestoreDb implements FirestoreDb {
  GameModel _gameModel = new GameModel();

  StreamController<Room> _roomStream;
  StreamController<Set<Player>> _playerStream;
  StreamController<List<Heist>> _heistStream;
  StreamController<List<Round>> _roundStream;

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
  Future<List<Round>> getRounds(String roomRef, String heistRef) {
    return new Future<List<Round>>.value(_gameModel.rounds[heistRef]);
  }

  @override
  StreamSubscription<List<Heist>> listenOnHeists(String roomRef, void onData(List<Heist> heists)) {
    _heistStream = new StreamController(onCancel: () => _heistStream.close(), sync: true);
    return _heistStream.stream.listen(onData);
  }

  @override
  StreamSubscription<Set<Player>> listenOnPlayers(String roomRef, void onData(Set<Player> players)) {
    _playerStream = new StreamController(onCancel: () => _playerStream.close(), sync: true);
    StreamSubscription<Set<Player>> subscription = _playerStream.stream.listen(onData);
    _postPlayer();
    return subscription;
  }

  void _postPlayer() {
    if (_playerStream != null && !_playerStream.isClosed && _gameModel.players != null) {
      _playerStream.add(_gameModel.players);
    }
  }

  @override
  StreamSubscription<Room> listenOnRoom(String code, void Function(Room room) onData) {
    _roomStream = new StreamController(onCancel: () => _roomStream.close(), sync: true);
    StreamSubscription<Room> subscription = _roomStream.stream.listen(onData);
    _postRoom();
    return subscription;
  }

  void _postRoom() {
    if (_roomStream != null && !_roomStream.isClosed && _gameModel.room != null) {
      _roomStream.add(_gameModel.room);
    }
  }

  @override
  StreamSubscription<List<Round>> listenOnRounds(
      String roomRef, String heistRef, void onData(List<Round> rounds)) {
    _roundStream = new StreamController(onCancel: () => _roundStream.close(), sync: true);
    return _roundStream.stream.listen(onData);
  }

  @override
  Future<void> upsertPlayer(Player player) {
    return new Future<void>(() {
      Set<Player> updated = new Set<Player>.from(_gameModel.players);
      updated.add(player);
      _gameModel = _gameModel.copyWith(players: updated);
      _postPlayer();
    });
  }

  @override
  Future<void> upsertRoom(Room room) {
    return new Future<void>(() {
      _gameModel = _gameModel.copyWith(room: room);
      _postRoom();
    });
  }
}
