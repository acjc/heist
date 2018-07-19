import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> heistIsActive = createSelector4(
    currentRound,
    currentHeist,
    biddingComplete,
    isAuction,
    (Round currentRound, Heist currentHeist, bool biddingComplete, bool isAuction) =>
        ((isAuction && biddingComplete) || currentRound.pot >= currentHeist.price) &&
        !currentHeist.allDecided);

final Selector<GameModel, bool> goingOnHeist =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.team.contains(me.id));

class Score {
  int thiefScore;
  int agentScore;

  Score(this.thiefScore, this.agentScore);

  Team get winner => thiefScore >= 3 ? Team.THIEVES : Team.AGENTS;
}

final Selector<GameModel, bool> gameOver = createSelector1(getHeists, (List<Heist> heists) {
  Score score = calculateScore(heists);
  return score.thiefScore >= 3 || score.agentScore >= 3;
});

Score calculateScore(List<Heist> heists) {
  int thiefScore = 0;
  int agentScore = 0;
  for (Heist heist in heists) {
    if (heist.allDecided) {
      if (heist.wasSuccess) {
        thiefScore++;
      } else {
        agentScore++;
      }
    }
  }
  return new Score(thiefScore, agentScore);
}
