import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () {
    String roundId = uuid();
    String hauntId = uuid();
    String playerId = uuid();
    Round round = Round(id: roundId, order: 1, haunt: hauntId, team: Set(), startedAt: now());
    Map<String, List<Round>> rounds = {
      hauntId: [round]
    };
    rounds = reduce(rounds, PickPlayerAction(roundId, playerId, 1));
    expect(round.team, contains(playerId));
    rounds = reduce(rounds, PickPlayerAction(roundId, uuid(), 1));
    expect(round.team, contains(playerId));
    expect(round.team.length, 1);
    rounds = reduce(rounds, RemovePlayerAction(roundId, playerId));
    expect(round.team, isEmpty);
  });
}
