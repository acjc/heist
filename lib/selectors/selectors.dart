part of heist;

final getRoom = (GameModel gameModel) => gameModel.room;
final getPlayers = (GameModel gameModel) => gameModel.players;
final getHeists = (GameModel gameModel) => gameModel.heists;
final getRounds = (GameModel gameModel) => gameModel.rounds;
final getBidAmount = (GameModel gameModel) => gameModel.bidAmount;
final getRequests = (GameModel gameModel) => gameModel.requests;

bool requestInProcess(GameModel gameModel, Request request) =>
    getRequests(gameModel).contains(request);

final Selector<GameModel, bool> rolesAreAssigned =
    createSelector1(getPlayers, (players) => players.any((p) => p.role == null || p.role.isEmpty));

/// A game is new if roles have not yet been assigned.
final Selector<GameModel, bool> isNewGame = createSelector3(rolesAreAssigned, getHeists, hasRounds,
    (rolesAreAssigned, heists, hasRounds) => rolesAreAssigned || heists.isEmpty || !hasRounds);

final Selector<GameModel, bool> hasRounds = createSelector1(getRounds,
    (rounds) => rounds.isNotEmpty && rounds.values.any((List<Round> rs) => rs.isNotEmpty));

final Selector<GameModel, bool> roomIsAvailable =
    createSelector1(getRoom, (room) => room.id != null);

final Selector<GameModel, bool> waitingForPlayers =
    createSelector2(getPlayers, getRoom, (players, room) => players.length < room.numPlayers);

final Selector<GameModel, bool> gameIsReady = createSelector5(
    roomIsAvailable,
    waitingForPlayers,
    isNewGame,
    getHeists,
    hasRounds,
    (roomIsAvailable, waitingForPlayers, isNewGame, heists, hasRounds) =>
        roomIsAvailable && !waitingForPlayers && !isNewGame && heists.isNotEmpty && hasRounds);

/// Selectors do not work if you return null
final getSelf = (GameModel gameModel) =>
    gameModel.players.singleWhere((p) => p.installId == installId(), orElse: () => null);

final Selector<GameModel, bool> haveJoinedGame =
    createSelector2(getSelf, getRoom, (me, room) => me != null && me.room?.documentID == room.id);

final Selector<GameModel, bool> amOwner =
    createSelector1(getRoom, (room) => room.owner == installId());

final Selector<GameModel, Heist> currentHeist = createSelector1(getHeists, (heists) => heists.last);

final Selector<GameModel, Round> currentRound = createSelector2(
    currentHeist, getRounds, (currentHeist, rounds) => rounds[currentHeist.id].last);

final Selector<GameModel, int> currentBalance =
    createSelector3(getSelf, getHeists, getRounds, (me, heists, allRounds) {
  int balance = me.initialBalance;
  heists.forEach((heist) {
    List<Round> rounds = allRounds[heist.id];
    if (heist.decisions.isNotEmpty) {
      balance -= rounds.last.bids[me.id].amount;
    }
    rounds.forEach((round) => round.gifts.forEach((id, gift) {
          if (id == me.id) {
            balance -= gift.amount;
          } else if (gift.recipient == me.id) {
            balance += gift.amount;
          }
        }));
  });
  // TODO: resolve output from heists
  return balance;
});

final Selector<GameModel, bool> currentHeistIsFunded =
    createSelector1(currentHeist, (currentHeist) => currentHeist.pot >= currentHeist.price);

final Selector<GameModel, bool> isMyGo =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.leader == me.id);

final Selector<GameModel, bool> waitingForTeam =
    createSelector1(currentRound, (currentRound) => !currentRound.teamSubmitted);

final Selector<GameModel, Bid> currentBid = createSelector2(
    currentRound, getSelf, (currentRound, me) => currentRound.bids[me.id] ?? new Bid(amount: -1));
