part of heist;

final roomReducer = combineReducers<Room>([
  new TypedReducer<Room, IncrementNumPlayersAction>(reduce),
  new TypedReducer<Room, DecrementNumPlayersAction>(reduce),
  new TypedReducer<Room, SetRoomCodeAction>(reduce),
  new TypedReducer<Room, UpdateStateAction<Room>>(reduce),
]);

class IncrementNumPlayersAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    if (room.numPlayers < maxPlayers) {
      return room.copyWith(numPlayers: room.numPlayers + 1);
    }
    return room;
  }
}

class DecrementNumPlayersAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    if (room.numPlayers > minPlayers) {
      return room.copyWith(numPlayers: room.numPlayers - 1);
    }
    return room;
  }
}

class SetRoomCodeAction extends Action<Room> {
  final String code;

  SetRoomCodeAction(this.code);

  @override
  Room reduce(Room room, action) {
    return room.copyWith(code: code);
  }
}
