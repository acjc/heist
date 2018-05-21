part of heist;

Future<QuerySnapshot> getRoom(String code) {
  return _roomQuery(code).getDocuments();
}

StreamSubscription<QuerySnapshot> listenOnRoom(String code, void onData(QuerySnapshot snapshot)) {
  return _roomQuery(code).snapshots().listen(onData);
}

Query _roomQuery(String code) {
  return Firestore.instance.collection('rooms').where('code', isEqualTo: code);
}

Future<QuerySnapshot> getPlayer(String installId, String roomRef) {
  return _playerQuery(installId, roomRef).getDocuments();
}

StreamSubscription<QuerySnapshot> listenOnPlayer(
    String installId, String roomRef, void onData(QuerySnapshot snapshot)) {
  return _playerQuery(installId, roomRef).snapshots().listen(onData);
}

Query _playerQuery(String installId, String roomRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  return Firestore.instance
      .collection('players')
      .where('installId', isEqualTo: installId)
      .where('room', isEqualTo: room);
}

Future<QuerySnapshot> getHeists(String roomRef) {
  return _heistQuery(roomRef).getDocuments();
}

StreamSubscription<QuerySnapshot> listenOnHeists(
    String roomRef, void onData(QuerySnapshot snapshot)) {
  return _heistQuery(roomRef).snapshots().listen(onData);
}

Query _heistQuery(String roomRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  return Firestore.instance.collection('heists').where('room', isEqualTo: room);
}

Future<QuerySnapshot> getRounds(String roomRef, String heistRef) {
  return _roundQuery(roomRef, heistRef).getDocuments();
}

StreamSubscription<QuerySnapshot> listenOnRounds(
    String roomRef, String heistRef, void onData(QuerySnapshot snapshot)) {
  return _roundQuery(roomRef, heistRef).snapshots().listen(onData);
}

Query _roundQuery(String roomRef, String heistRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  DocumentReference heist = Firestore.instance.document("/heists/$heistRef");
  return Firestore.instance
      .collection('rounds')
      .where('room', isEqualTo: room)
      .where('heist', isEqualTo: heist);
}

Future<void> upsertRoom(Room room) {
  return Firestore.instance.collection('rooms').document(room.id).setData(room.toJson());
}

Future<void> upsertPlayer(Player player) {
  return Firestore.instance.collection('players').document(player.id).setData(player.toJson());
}
