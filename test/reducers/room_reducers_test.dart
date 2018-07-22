import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/player_reducers.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/room_reducers.dart';
import 'package:test/test.dart';

void main() {
  test('increment numPlayers', () {
    Room room = new Room(numPlayers: maxPlayers - 1, roles: new Set());
    room = reduce(room, new IncrementNumPlayersAction());
    expect(room.numPlayers, maxPlayers);
    room = reduce(room, new IncrementNumPlayersAction());
    expect(room.numPlayers, maxPlayers);
  });

  test('decrement numPlayers', () {
    Room room = new Room(numPlayers: minPlayers + 1, roles: new Set());
    room = reduce(room, new DecrementNumPlayersAction());
    expect(room.numPlayers, minPlayers);
    room = reduce(room, new DecrementNumPlayersAction());
    expect(room.numPlayers, minPlayers);
  });

  test('set room code', () {
    Room room = new Room(numPlayers: 5, roles: new Set());
    Room updatedRoom = reduce(room, new SetRoomCodeAction('ABCD'));
    expect(updatedRoom.code, 'ABCD');
  });

  test('set player name', () {
    String playerName = reduce(null, new SetPlayerNameAction('_name'));
    expect(playerName, '_name');
  });

  test('set install ID', () {
    String installId = reduce(null, new SetPlayerInstallIdAction('_id'));
    expect(installId, '_id');
  });
}
