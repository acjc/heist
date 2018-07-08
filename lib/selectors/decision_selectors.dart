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
