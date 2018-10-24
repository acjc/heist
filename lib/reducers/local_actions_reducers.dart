import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final localActionsReducer = combineReducers<LocalActions>([
  TypedReducer<LocalActions, RecordLocalHauntActionAction>(reduce),
  TypedReducer<LocalActions, RecordLocalRoundActionAction>(reduce),
  TypedReducer<LocalActions, RecordGeneralLocalActionAction>(reduce),
  TypedReducer<LocalActions, UpdateStateAction<LocalActions>>(reduce),
]);

class RecordLocalHauntActionAction extends Action<LocalActions> {
  final String hauntId;
  final LocalHauntAction newAction;

  RecordLocalHauntActionAction(this.hauntId, this.newAction);

  @override
  LocalActions reduce(LocalActions localActions, action) {
    Map<String, Set<LocalHauntAction>> updated = Map.of(localActions.hauntActions);
    updated.update(hauntId, (currentActions) {
      currentActions.add(newAction);
      return currentActions;
    }, ifAbsent: () => Set.of([newAction]));

    return localActions.copyWith(hauntActions: updated);
  }
}

class RecordLocalRoundActionAction extends Action<LocalActions> {
  final String roundId;
  final LocalRoundAction newAction;

  RecordLocalRoundActionAction(this.roundId, this.newAction);

  @override
  LocalActions reduce(LocalActions localActions, action) {
    Map<String, Set<LocalRoundAction>> updated = Map.of(localActions.roundActions);
    updated.update(roundId, (currentActions) {
      currentActions.add(newAction);
      return currentActions;
    }, ifAbsent: () => Set.of([newAction]));

    return localActions.copyWith(roundActions: updated);
  }
}

class RecordGeneralLocalActionAction extends Action<LocalActions> {
  final GeneralLocalAction newAction;

  RecordGeneralLocalActionAction(this.newAction);

  @override
  LocalActions reduce(LocalActions localActions, action) {
    Set<GeneralLocalAction> updated = Set.of(localActions.generalActions);
    updated.add(newAction);
    return localActions.copyWith(generalActions: updated);
  }
}
