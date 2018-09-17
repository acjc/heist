import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';

bool localHauntActionRecorded(GameModel gameModel, String hauntId, LocalHauntAction action) {
  Set<LocalHauntAction> localActions = getLocalActions(gameModel).localHauntActions[hauntId];
  if (localActions != null) {
    return localActions.contains(action);
  }
  return false;
}

bool localRoundActionRecorded(GameModel gameModel, String roundId, LocalRoundAction action) {
  Set<LocalRoundAction> localActions = getLocalActions(gameModel).localRoundActions[roundId];
  if (localActions != null) {
    return localActions.contains(action);
  }
  return false;
}
