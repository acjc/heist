part of heist;

Future<QuerySnapshot> getRoom(String code) {
  return Firestore.instance.collection('rooms').where('code', isEqualTo: code).getDocuments();
}

Future<QuerySnapshot> getPlayer(String installId, String roomRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  return Firestore.instance
      .collection('players')
      .where('installId', isEqualTo: installId)
      .where('room', isEqualTo: room)
      .getDocuments();
}

Future<QuerySnapshot> getHeists(String roomRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  return Firestore.instance
      .collection('heists')
      .where('room', isEqualTo: room)
      .getDocuments();
}

Future<QuerySnapshot> getRounds(String roomRef, String heistRef) {
  DocumentReference room = Firestore.instance.document("/rooms/$roomRef");
  DocumentReference heist = Firestore.instance.document("/heists/$heistRef");
  return Firestore.instance
      .collection('rounds')
      .where('room', isEqualTo: room)
      .where('heist', isEqualTo: heist)
      .getDocuments();
}
