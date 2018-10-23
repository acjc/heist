import 'package:heist/db/database_model.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final roundReducer = combineReducers<Map<String, List<Round>>>([
  TypedReducer<Map<String, List<Round>>, PickPlayerAction>(reduce),
  TypedReducer<Map<String, List<Round>>, RemovePlayerAction>(reduce),
  TypedReducer<Map<String, List<Round>>, UpdateStateAction<Map<String, List<Round>>>>(reduce),
]);

Round findRound(Map<String, List<Round>> rounds, String roundId) =>
    rounds.values.expand((rs) => rs).singleWhere((r) => r.id == roundId);

class PickPlayerAction extends Action<Map<String, List<Round>>> {
  final String roundId;
  final String playerId;

  PickPlayerAction(this.roundId, this.playerId);

  @override
  Map<String, List<Round>> reduce(Map<String, List<Round>> rounds, action) {
    Map<String, List<Round>> updated = new Map.of(rounds);
    Round round = findRound(updated, roundId);
    round.team.add(playerId);
    return updated;
  }
}

class RemovePlayerAction extends Action<Map<String, List<Round>>> {
  final String roundId;
  final String playerId;

  RemovePlayerAction(this.roundId, this.playerId);

  @override
  Map<String, List<Round>> reduce(Map<String, List<Round>> rounds, action) {
    Map<String, List<Round>> updated = new Map.of(rounds);
    Round round = findRound(updated, roundId);
    round.team.remove(playerId);
    return updated;
  }
}
