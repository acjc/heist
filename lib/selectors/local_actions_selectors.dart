import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';

bool localHauntActionRecorded(GameModel gameModel, String hauntId, LocalHauntAction action) {
  Set<LocalHauntAction> localActions = getLocalActions(gameModel).localHauntActions[hauntId];
  return localActions != null && localActions.contains(action);
}

bool localRoundActionRecorded(GameModel gameModel, String roundId, LocalRoundAction action) {
  Set<LocalRoundAction> localActions = getLocalActions(gameModel).localRoundActions[roundId];
  return localActions != null && localActions.contains(action);
}
