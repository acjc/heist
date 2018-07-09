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

final Selector<GameModel, int> currentPot = createSelector1(
    currentRound,
    (Round currentRound) => currentRound.bids.isNotEmpty
        ? currentRound.bids.values.fold(0, (previousValue, bid) => previousValue + bid.amount)
        : -1);

final Selector<GameModel, bool> gameOver = createSelector1(getHeists, (List<Heist> heists) {
  int thiefScore = 0;
  int agentScore = 0;
  for (Heist heist in heists) {
    List<String> decisions = heist.decisions.values;
    int steals = decisions.where((d) => d == 'STEAL').length;
    if (decisions.contains('FAIL') || steals >= 2) {
      agentScore++;
    } else {
      thiefScore++;
    }
  }
  return thiefScore >= 3 || agentScore >= 3;
});
