import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final roundReducer = combineReducers<Map<String, List<Round>>>([
  TypedReducer<Map<String, List<Round>>, UpdateStateAction<Map<String, List<Round>>>>(reduce),
  TypedReducer<Map<String, List<Round>>, PickPlayerAction>(reduce),
]);

class PickPlayerAction extends Action<Map<String, List<Round>>> {
  final String roundId;
  final String playerId;

  PickPlayerAction(this.roundId, this.playerId);

  @override
  Map<String, List<Round>> reduce(Map<String, List<Round>> rounds, action) {
    Map<String, List<Round>> updated = Map.from(rounds);
    Round round = roundById(updated, roundId);
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
    Map<String, List<Round>> updated = Map.of(rounds);
    Round round = roundById(updated, roundId);
    round.team.remove(playerId);
    return updated;
  }
}
