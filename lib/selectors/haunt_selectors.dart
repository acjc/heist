import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> hauntIsActive = createSelector4(
    getRounds, currentHaunt, biddingComplete, isAuction,
    (Map<String, List<Round>> rounds, Haunt currentHaunt, bool biddingComplete, bool isAuction) {
  bool priceMet = rounds[currentHaunt.id]
      .any((r) => r.pot >= currentHaunt.price && r.exclusionsSubmitted && r.complete);
  return ((isAuction && biddingComplete) || priceMet) &&
      !currentHaunt.complete &&
      !currentHaunt.allDecided;
});

final Selector<GameModel, bool> haveBeenExcluded =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.team.contains(me.id));

class Score {
  int scaryScore;
  int friendlyScore;

  Score(this.scaryScore, this.friendlyScore);

  Team get winner => scaryScore >= 3 ? Team.SCARY : Team.FRIENDLY;
}

final Selector<GameModel, bool> gameOver = createSelector1(getHaunts, (List<Haunt> haunts) {
  Score score = calculateScore(haunts);
  return score.scaryScore >= 3 || score.friendlyScore >= 3;
});

Score calculateScore(List<Haunt> haunts) {
  int scaryScore = 0;
  int friendlyScore = 0;
  for (Haunt haunt in haunts) {
    if (haunt.allDecided) {
      if (haunt.wasSuccess) {
        scaryScore++;
      } else {
        friendlyScore++;
      }
    }
  }
  return Score(scaryScore, friendlyScore);
}
