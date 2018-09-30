import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';

bool localHauntActionRecorded(LocalActions localActions, String hauntId, LocalHauntAction action) {
  Set<LocalHauntAction> localHauntActions = localActions.localHauntActions[hauntId];
  return localHauntActions != null && localHauntActions.contains(action);
}

bool localRoundActionRecorded(LocalActions localActions, String roundId, LocalRoundAction action) {
  Set<LocalRoundAction> localRoundActions = localActions.localRoundActions[roundId];
  return localRoundActions != null && localRoundActions.contains(action);
}

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
