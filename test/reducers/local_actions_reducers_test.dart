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
    expect(localActions.localRoundActions.length, 1);
    expect(localActions.localRoundActions[roundId], contains(LocalRoundAction.RoundEndContinue));
  });

  test('test record local haunt action', () {
    String hauntId = uuid();
    LocalActions localActions = LocalActions.initial();

    localActions = reduce(
      localActions,
      RecordLocalHauntActionAction(hauntId, LocalHauntAction.HauntEndContinue),
    );
    expect(localActions.localHauntActions.length, 1);
    expect(localActions.localHauntActions[hauntId], contains(LocalHauntAction.HauntEndContinue));
  });
}
