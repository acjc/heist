import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> hauntIsActive = createSelector4(
    currentRound,
    currentHaunt,
    biddingComplete,
    isAuction,
    (Round currentRound, Haunt currentHaunt, bool biddingComplete, bool isAuction) =>
        ((isAuction && biddingComplete) || currentRound.pot >= currentHaunt.price) &&
        !currentHaunt.allDecided);

final Selector<GameModel, bool> goingOnHaunt =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.team.contains(me.id));

class Score {
  int scaryScore;
  int friendlyScore;

  Score(this.scaryScore, this.friendlyScore);

  Team get winner => scaryScore >= 3 ? Team.SCARY : Team.FRIENDLY;
}

final Selector<GameModel, bool> gameOver = createSelector1(getHaunts, (List<Haunt> heists) {
  Score score = calculateScore(heists);
  return score.scaryScore >= 3 || score.friendlyScore >= 3;
});

Score calculateScore(List<Haunt> heists) {
  int scaryScore = 0;
  int friendlyScore = 0;
  for (Haunt heist in heists) {
    if (heist.allDecided) {
      if (heist.wasSuccess) {
        scaryScore++;
      } else {
        friendlyScore++;
      }
    }
  }
  return new Score(scaryScore, friendlyScore);
}
