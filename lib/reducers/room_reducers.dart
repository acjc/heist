part of heist;

final roomReducer = combineReducers<Room>([
  new TypedReducer<Room, IncrementNumPlayersAction>(reduce),
  new TypedReducer<Room, DecrementNumPlayersAction>(reduce),
  new TypedReducer<Room, EnterCodeAction>(reduce),
  new TypedReducer<Room, EnterRoomAction>(reduce),
]);

class IncrementNumPlayersAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    if (room.numPlayers < _maxPlayers) {
      return room.copyWith(numPlayers: room.numPlayers + 1);
    }
    return room;
  }
}

class DecrementNumPlayersAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    if (room.numPlayers > _minPlayers) {
      return room.copyWith(numPlayers: room.numPlayers - 1);
    }
    return room;
  }
}

class EnterCodeAction extends Action<Room> {
  final String code;

  EnterCodeAction(this.code);

  @override
  Room reduce(Room room, action) {
    return room.copyWith(code: code);
  }
}

class EnterRoomAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    navigatorKey.currentState
        .push(new MaterialPageRoute(builder: (context) => new Game(room.code)));
    return room;
  }
}
