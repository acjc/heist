import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';

bool localHauntActionRecorded(GameModel gameModel, String hauntId, LocalHauntAction action) =>
    getLocalActions(gameModel).localHauntActions[hauntId]?.contains(action);

bool localRoundActionRecorded(GameModel gameModel, String roundId, LocalRoundAction action) =>
    getLocalActions(gameModel).localRoundActions[roundId]?.contains(action);
