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
      int newNumPlayers = room.numPlayers + 1;
      Set<String> roles = getRoleIds(numPlayersToRolesMap[newNumPlayers]);
      return room.copyWith(numPlayers: newNumPlayers, roles: roles);
    }
    return room;
  }
}

class DecrementNumPlayersAction extends Action<Room> {
  @override
  Room reduce(Room room, action) {
    if (room.numPlayers > minPlayers) {
      int newNumPlayers = room.numPlayers - 1;
      Set<String> roles = getRoleIds(numPlayersToRolesMap[newNumPlayers]);
      return room.copyWith(numPlayers: newNumPlayers, roles: roles);
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
