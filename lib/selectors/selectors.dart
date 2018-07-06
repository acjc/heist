part of heist;

final getRoom = (GameModel gameModel) => gameModel.room;
final getPlayers = (GameModel gameModel) => gameModel.players;
final getHeists = (GameModel gameModel) => gameModel.heists;
final getRounds = (GameModel gameModel) => gameModel.rounds;
final getPlayerName = (GameModel gameModel) => gameModel.playerName;
final getBidAmount = (GameModel gameModel) => gameModel.bidAmount;
final getRequests = (GameModel gameModel) => gameModel.requests;

bool requestInProcess(GameModel gameModel, Request request) =>
    getRequests(gameModel).contains(request);

final Selector<GameModel, bool> rolesAreAssigned =
    createSelector1(getPlayers, (players) => players.any((p) => p.role == null || p.role.isEmpty));

/// A game is new if roles have not yet been assigned
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

// Selectors do not seem to work if you ever return null
final getSelf = (GameModel gameModel) =>
    getPlayers(gameModel).singleWhere((p) => p.installId == installId(), orElse: () => null);

final Selector<GameModel, bool> haveJoinedGame =
    createSelector2(getSelf, getRoom, (me, room) => me != null && me.room?.documentID == room.id);

final Selector<GameModel, bool> amOwner =
    createSelector1(getRoom, (room) => room.owner == installId());

// Reselect would not recognise changes to the current heist
final currentHeist = (GameModel gameModel) => getHeists(gameModel).last;

final Selector<GameModel, Round> currentRound = createSelector2(
    currentHeist, getRounds, (currentHeist, rounds) => rounds[currentHeist.id].last);

final Selector<GameModel, int> currentBalance = createSelector3(getSelf, getHeists, getRounds,
    (Player me, List<Heist> heists, Map<String, List<Round>> allRounds) {
  int balance = me.initialBalance;
  heists.forEach((heist) {
    List<Round> rounds = allRounds[heist.id];
    if (heist.decisions.length == heist.numPlayers) {
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

final Selector<GameModel, bool> isAuction =
    createSelector1((currentRound), (Round currentRound) => currentRound.order == 5);

final Selector<GameModel, bool> heistIsActive = createSelector5(
    currentPot,
    currentHeist,
    biddingComplete,
    isAuction,
    heistDecided,
    (int currentPot, Heist currentHeist, bool biddingComplete, bool isAuction, bool heistDecided) =>
        ((isAuction && biddingComplete) || currentPot >= currentHeist.price) && !heistDecided);

final Selector<GameModel, bool> isMyGo =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.leader == me.id);

final Selector<GameModel, Player> roundLeader = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) =>
        players.singleWhere((Player p) => p.id == currentRound.leader));

final Selector<GameModel, Set<Player>> playersInTeam = createSelector2(
    getPlayers,
    currentRound,
    (players, currentRound) => players.where((Player p) {
          // Reselect needed this bool explicitly typed
          bool playerInTeam = currentRound.team.contains(p.id);
          return playerInTeam;
        }).toSet());

// Reselect could not handle Set<String>
final teamNames =
    (GameModel gameModel) => playersInTeam(gameModel).map((Player p) => p.name).toSet();

// Reselect could not handle Set<String>
final teamIds = (GameModel gameModel) => playersInTeam(gameModel).map((Player p) => p.id).toSet();

final Selector<GameModel, int> numBids = createSelector1(
    currentRound, (currentRound) => currentRound.bids.values.where((b) => b != null).length);

final Selector<GameModel, bool> biddingComplete =
    createSelector2(numBids, getRoom, (numBids, room) => numBids == room.numPlayers);

final Selector<GameModel, Bid> myCurrentBid =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.bids[me.id]);

final Selector<GameModel, bool> goingOnHeist = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.team.contains(me.id));

final Selector<GameModel, bool> heistDecided = createSelector1(
    currentHeist, (Heist currentHeist) => currentHeist.decisions.length == currentHeist.numPlayers);

final Selector<GameModel, int> currentPot = createSelector1(
    currentRound,
    (Round currentRound) => currentRound.bids.isNotEmpty
        ? currentRound.bids.values.fold(0, (previousValue, bid) => previousValue + bid.amount)
        : -1);
