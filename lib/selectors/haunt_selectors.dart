import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

bool hauntHasActiveRound(Room room, Map<String, List<Round>> rounds, Haunt haunt) =>
    rounds[haunt.id].any((r) =>
        r.teamSubmitted &&
        r.bids.length == room.numPlayers &&
        (r.isAuction || r.pot >= haunt.price));

final Selector<GameModel, bool> currentHauntIsActive = createSelector3(
    getRoom,
    getRounds,
    currentHaunt,
    (Room room, Map<String, List<Round>> rounds, Haunt currentHaunt) =>
        hauntHasActiveRound(room, rounds, currentHaunt) &&
        !currentHaunt.allDecided &&
        !currentHaunt.complete);

bool goingOnHaunt(GameModel gameModel) =>
    currentRound(gameModel).team.contains(getSelf(gameModel).id);

Player leaderForHaunt(GameModel gameModel, Haunt haunt) {
  Round lastRoundThatHappened = lastRoundForHaunt(getRoom(gameModel), getRounds(gameModel), haunt);
  if (!lastRoundThatHappened.isAuction) {
    return leaderForRound(gameModel, lastRoundThatHappened);
  } else {
    return null;
  }
}

class Score {
  int scaryScore;
  int friendlyScore;

  Score(this.scaryScore, this.friendlyScore);

  Team get winner => scaryScore >= 3 ? Team.SCARY : Team.FRIENDLY;

  bool get gameOver => scaryScore >= 3 || friendlyScore >= 3;
}

final Selector<GameModel, bool> gameOver =
    createSelector1(getHaunts, (List<Haunt> haunts) => calculateScore(haunts).gameOver);

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
