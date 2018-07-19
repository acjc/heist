import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () {
    String roundId = uuid();
    String heistId = uuid();
    String playerId = uuid();
    Round round =
        new Round(id: roundId, order: 1, heist: heistId, team: new Set(), startedAt: now());
    Map<String, List<Round>> rounds = {
      heistId: [round]
    };
    rounds = reduce(rounds, new PickPlayerAction(roundId, playerId));
    expect(round.team, contains(playerId));
    rounds = reduce(rounds, new RemovePlayerAction(roundId, playerId));
    expect(round.team, isEmpty);
  });
}
