part of heist;

final Selector<GameModel, Gift> myCurrentGift = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.gifts[me.id]);
