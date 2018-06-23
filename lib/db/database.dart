part of heist;

class FirestoreDb {
  final Firestore _firestore;

  FirestoreDb(this._firestore);

  Future<Room> getRoom(String id) async {
    DocumentSnapshot snapshot = await _firestore.document("rooms/$id").get();
    return new Room.fromSnapshot(snapshot);
  }

  Future<Room> getRoomByCode(String code) async {
    assert(code.length == 4);
    QuerySnapshot snapshot = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .where('completed', isEqualTo: false)
        // TODO: this is commented out during development
//        .where('createdAt',
//            isGreaterThanOrEqualTo: now().add(new Duration(days: -1)))
        .getDocuments();
    if (snapshot.documents.isNotEmpty) {
      return new Room.fromSnapshot(snapshot.documents.first);
    }
    return null;
  }

  Future<bool> roomExistsWithCode(String code) async {
    return await getRoomByCode(code) != null;
  }

  Future<bool> playerExists(String roomId, String installId) async {
    QuerySnapshot snapshot =
        await _playerQuery(roomId).where('installId', isEqualTo: installId).getDocuments();
    return snapshot.documents.isNotEmpty;
  }

  Future<Heist> getHeist(String roomId, int order) async {
    QuerySnapshot snapshot =
        await _heistQuery(roomId).where('order', isEqualTo: order).getDocuments();
    return snapshot.documents.isNotEmpty ? new Heist.fromSnapshot(snapshot.documents.first) : null;
  }

  Future<bool> roundExists(String roomId, String heistId, int order) async {
    QuerySnapshot snapshot = await _roundQuery(roomId)
        .where('heist', isEqualTo: heistId)
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
      players.sort((p1, p2) => p1.order.compareTo(p2.order));
      return players;
    }).listen(onData);
  }

  Query _playerQuery(String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    return _firestore.collection('players').where('room', isEqualTo: roomRef);
  }

  Future<List<Heist>> getHeists(String roomRef) async {
    QuerySnapshot snapshot = await _heistQuery(roomRef).getDocuments();
    List<Heist> heists = snapshot.documents.map((s) => new Heist.fromSnapshot(s)).toList();
    heists.sort((h1, h2) => h1.order.compareTo(h2.order));
    return heists;
  }

  StreamSubscription<List<Heist>> listenOnHeists(String roomRef, void onData(List<Heist> heists)) {
    return _heistQuery(roomRef).snapshots().map((snapshot) {
      List<Heist> heists = snapshot.documents.map((s) => new Heist.fromSnapshot(s)).toList();
      heists.sort((h1, h2) => h1.order.compareTo(h2.order));
      return heists;
    }).listen(onData);
  }

  Query _heistQuery(String roomRef) {
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

  Future<String> upsertHeist(Heist heist, String roomId) async {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    heist = heist.copyWith(room: roomRef);
    DocumentReference heistRef = _firestore.collection('heists').document(heist.id);
    await heistRef.setData(heist.toJson());
    return heistRef.documentID;
  }

  Future<void> upsertRound(Round round, String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    round = round.copyWith(room: roomRef);
    return _firestore.collection('rounds').document(round.id).setData(round.toJson());
  }

  Future<void> upsertPlayer(Player player, String roomId) {
    DocumentReference roomRef = _firestore.document("/rooms/$roomId");
    player = player.copyWith(room: roomRef);
    return _firestore.collection('players').document(player.id).setData(player.toJson());
  }

  Future<void> submitBid(String roundId, String myPlayerId, Bid bid) {
    Map<String, dynamic> data = {
      'bids': {myPlayerId: bid?.toJson()}
    };
    return _firestore.collection('rounds').document(roundId).setData(data, merge: true);
  }

  Future<void> cancelBid(String roundId, String myPlayerId) {
    return submitBid(roundId, myPlayerId, null);
  }
}
