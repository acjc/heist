import 'dart:async';

import 'package:heist/main.dart';

class MockFirestoreDb implements FirestoreDb {
  GameModel gameModel = new GameModel();

  StreamController<Room> roomStream;
  StreamController<Player> playerStream;
  StreamController<List<Heist>> heistStream;
  StreamController<List<Round>> roundStream;

  @override
  Future<List<Heist>> getHeists(String roomRef) {
    return new Future<List<Heist>>.value(gameModel.heists);
  }

  @override
  Future<Player> getPlayer(String installId, String roomRef) {
    return new Future<Player>.value(gameModel.player);
  }

  @override
  Future<Room> getRoom(String code) {
    return new Future<Room>.value(gameModel.room);
  }

  @override
  Future<List<Round>> getRounds(String roomRef, String heistRef) {
    return new Future<List<Round>>.value(gameModel.rounds[heistRef]);
  }

  @override
  StreamSubscription<List<Heist>> listenOnHeists(String roomRef, void onData(List<Heist> heists)) {
    heistStream = new StreamController(onCancel: () => heistStream.close(), sync: true);
    return heistStream.stream.listen(onData);
  }

  @override
  StreamSubscription<Player> listenOnPlayer(
      String installId, String roomRef, void onData(Player player)) {
    playerStream = new StreamController(onCancel: () => playerStream.close(), sync: true);
    StreamSubscription<Player> subscription = playerStream.stream.listen(onData);
    _postPlayer();
    return subscription;
  }

  void _postPlayer() {
    if (playerStream != null && !playerStream.isClosed && gameModel.player != null) {
      playerStream.add(gameModel.player);
    }
  }

  @override
  StreamSubscription<Room> listenOnRoom(String code, void Function(Room room) onData) {
    roomStream = new StreamController(onCancel: () => roomStream.close(), sync: true);
    StreamSubscription<Room> subscription = roomStream.stream.listen(onData);
    _postRoom();
    return subscription;
  }

  void _postRoom() {
    if (roomStream != null && !roomStream.isClosed && gameModel.room != null) {
      roomStream.add(gameModel.room);
    }
  }

  @override
  StreamSubscription<List<Round>> listenOnRounds(
      String roomRef, String heistRef, void onData(List<Round> rounds)) {
    roundStream = new StreamController(onCancel: () => roundStream.close(), sync: true);
    return roundStream.stream.listen(onData);
  }

  @override
  Future<void> upsertPlayer(Player player) {
    return new Future<void>(() {
      gameModel = gameModel.copyWith(player: player);
      _postPlayer();
    });
  }

  @override
  Future<void> upsertRoom(Room room) {
    return new Future<void>(() {
      gameModel = gameModel.copyWith(room: room);
      _postRoom();
    });
  }
}
