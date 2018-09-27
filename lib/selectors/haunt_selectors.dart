import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

bool hauntHasActiveRound(Room room, Haunt haunt, Map<String, List<Round>> rounds) =>
    rounds[haunt.id].any((r) =>
        r.complete &&
        r.teamSubmitted &&
        r.bids.length == room.numPlayers &&
        (r.isAuction || r.pot >= haunt.price));

bool hauntIsActive(Room room, Haunt haunt, Map<String, List<Round>> rounds) =>
    hauntHasActiveRound(room, haunt, rounds) != null && !haunt.allDecided && !haunt.complete;

final Selector<GameModel, bool> currentHauntIsActive = createSelector3(
    getRoom,
    currentHaunt,
    getRounds,
    (Room room, Haunt currentHaunt, Map<String, List<Round>> rounds) =>
        hauntIsActive(room, currentHaunt, rounds));

final Selector<GameModel, bool> goingOnHaunt = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.team.contains(me.id));

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
