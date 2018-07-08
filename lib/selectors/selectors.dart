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

// Selectors do not seem to work if you ever return null
final getSelf = (GameModel gameModel) =>
    getPlayers(gameModel).singleWhere((p) => p.installId == installId(), orElse: () => null);

final getPlayerByRoleId =
    (GameModel gameModel, String role) => getPlayers(gameModel).singleWhere((p) => p.role == role);

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
