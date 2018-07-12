part of heist;

final Selector<GameModel, bool> heistIsActive = createSelector5(
    currentPot,
    currentHeist,
    biddingComplete,
    isAuction,
    heistDecided,
    (int currentPot, Heist currentHeist, bool biddingComplete, bool isAuction, bool heistDecided) =>
        ((isAuction && biddingComplete) || currentPot >= currentHeist.price) && !heistDecided);

final Selector<GameModel, bool> goingOnHeist = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.team.contains(me.id));

final Selector<GameModel, bool> heistDecided = createSelector1(
    currentHeist, (Heist currentHeist) => currentHeist.decisions.length == currentHeist.numPlayers);

final Selector<GameModel, int> currentPot =
    createSelector1(currentRound, (Round currentRound) => currentRound.pot);

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
    if (heist.wasSuccess) {
      thiefScore++;
    } else {
      agentScore++;
    }
  }
  return new Score(thiefScore, agentScore);
}
