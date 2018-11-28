import 'package:heist/reducers/local_actions_reducers.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/state.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test record local round action', () {
    String roundId = uuid();
    LocalActions localActions = LocalActions.initial();

    localActions = reduce(
      localActions,
      RecordLocalRoundActionAction(roundId, LocalRoundAction.RoundEndContinue),
    );
    expect(localActions.roundActions.length, 1);
    expect(localActions.roundActions[roundId], contains(LocalRoundAction.RoundEndContinue));
  });

  test('test record local haunt action', () {
    String hauntId = uuid();
    LocalActions localActions = LocalActions.initial();

    localActions = reduce(
      localActions,
      RecordLocalHauntActionAction(hauntId, LocalHauntAction.HauntEndContinue),
    );
    expect(localActions.hauntActions.length, 1);
    expect(localActions.hauntActions[hauntId], contains(LocalHauntAction.HauntEndContinue));
  });

  test('test record general local action', () {
    LocalActions localActions = LocalActions.initial();

    localActions = reduce(
      localActions,
      RecordGeneralLocalActionAction(GeneralLocalAction.SecretDescriptionClosed),
    );
    expect(localActions.generalActions.length, 1);
    expect(localActions.generalActions, contains(GeneralLocalAction.SecretDescriptionClosed));
  });
}
