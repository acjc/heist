import 'package:heist/reducers/form_reducers.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:test/test.dart';

void main() {
  test('save room code', () {
    String roomCode = reduce(null, new SaveRoomCodeAction('ABCD'));
    expect(roomCode, 'ABCD');
  });

  test('save player name', () {
    String playerName = reduce(null, new SavePlayerNameAction('_name'));
    expect(playerName, '_name');
  });

  test('set install ID', () {
    String installId = reduce(null, new SavePlayerInstallIdAction('_id'));
    expect(installId, '_id');
  });
}
