part of heist;

class FirestoreDb {
  final Firestore _firestore;

  FirestoreDb(this._firestore);

  Future<Room> getRoom(String code) async {
    QuerySnapshot snapshot = await _roomQuery(code).getDocuments();
    return new Room.fromSnapshot(snapshot.documents[0]);
  }

  Future<bool> roomExists(String code) async {
    QuerySnapshot snapshot = await _roomQuery(code)
        .where('completed', isEqualTo: false)
        .where('createdAt', isGreaterThanOrEqualTo: new DateTime.now().add(new Duration(days: -1)))
        .getDocuments();
    return snapshot.documents.isNotEmpty;
  }

  StreamSubscription<Room> listenOnRoom(String code, void onData(Room room)) {
    return _roomQuery(code)
        .snapshots()
        .map((snapshot) => new Room.fromSnapshot(snapshot.documents[0]))
        .listen(onData);
  }

  Query _roomQuery(String code) {
    return _firestore.collection('rooms').where('code', isEqualTo: code);
  }

  Future<Player> getPlayer(String installId, String roomRef) async {
    QuerySnapshot snapshot = await _playerQuery(installId, roomRef).getDocuments();
    return new Player.fromSnapshot(snapshot.documents[0]);
  }

  StreamSubscription<Player> listenOnPlayer(
      String installId, String roomRef, void onData(Player player)) {
    return _playerQuery(installId, roomRef)
        .snapshots()
        .map((snapshot) => new Player.fromSnapshot(snapshot.documents[0]))
        .listen(onData);
  }

  Query _playerQuery(String installId, String roomRef) {
    DocumentReference room = _firestore.document("/rooms/$roomRef");
    return _firestore
        .collection('players')
        .where('installId', isEqualTo: installId)
        .where('room', isEqualTo: room);
  }

  Future<List<Heist>> getHeists(String roomRef) async {
    QuerySnapshot snapshot = await _heistQuery(roomRef).getDocuments();
    return snapshot.documents.map((s) => new Heist.fromSnapshot(s)).toList();
  }

  StreamSubscription<List<Heist>> listenOnHeists(String roomRef, void onData(List<Heist> heists)) {
    return _heistQuery(roomRef)
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => new Heist.fromSnapshot(s)).toList())
        .listen(onData);
  }

  Query _heistQuery(String roomRef) {
    DocumentReference room = _firestore.document("/rooms/$roomRef");
    return _firestore.collection('heists').where('room', isEqualTo: room);
  }

  Future<List<Round>> getRounds(String roomRef, String heistRef) async {
    QuerySnapshot snapshot = await _roundQuery(roomRef, heistRef).getDocuments();
    return snapshot.documents.map((s) => new Round.fromSnapshot(s)).toList();
  }

  StreamSubscription<List<Round>> listenOnRounds(
      String roomRef, String heistRef, void onData(List<Round> rounds)) {
    return _roundQuery(roomRef, heistRef)
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => new Round.fromSnapshot(s)).toList())
        .listen(onData);
  }

  Query _roundQuery(String roomRef, String heistRef) {
    DocumentReference room = _firestore.document("/rooms/$roomRef");
    DocumentReference heist = _firestore.document("/heists/$heistRef");
    return _firestore
        .collection('rounds')
        .where('room', isEqualTo: room)
        .where('heist', isEqualTo: heist);
  }

  Future<void> upsertRoom(Room room) {
    return _firestore.collection('rooms').document(room.id).setData(room.toJson());
  }

  Future<void> upsertPlayer(Player player) {
    return _firestore.collection('players').document(player.id).setData(player.toJson());
  }
}
