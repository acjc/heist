import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';

bool localHauntActionRecorded(LocalActions localActions, String hauntId, LocalHauntAction action) {
  Set<LocalHauntAction> hauntActions = localActions.hauntActions[hauntId];
  return hauntActions != null && hauntActions.contains(action);
}

bool localRoundActionRecorded(LocalActions localActions, String roundId, LocalRoundAction action) {
  Set<LocalRoundAction> roundActions = localActions.roundActions[roundId];
  return roundActions != null && roundActions.contains(action);
}

bool generalLocalActionRecorded(GameModel gameModel, GeneralLocalAction action) =>
    getLocalActions(gameModel).generalActions.contains(action);

bool roundContinued(LocalActions localActions, Round round) => localRoundActionRecorded(
      localActions,
      round.id,
      LocalRoundAction.RoundEndContinue,
    );

bool teamSelectionContinued(LocalActions localActions, Round currentRound) =>
    localRoundActionRecorded(
      localActions,
      currentRound.id,
      LocalRoundAction.TeamSelectionContinue,
    );

bool hauntContinued(LocalActions localActions, Haunt haunt) => localHauntActionRecorded(
      localActions,
      haunt.id,
      LocalHauntAction.HauntEndContinue,
    );
