part of heist;

// Selectors do not seem to work if you ever return null
final getSelf = (GameModel gameModel) =>
    getPlayers(gameModel).singleWhere((p) => p.installId == installId(), orElse: () => null);

final getPlayerByRoleId =
    (GameModel gameModel, String role) => getPlayers(gameModel).singleWhere((p) => p.role == role);

final getPlayerById =
    (GameModel gameModel, String id) => getPlayers(gameModel).singleWhere((p) => p.id == id);

final Selector<GameModel, List<Player>> getOtherPlayers = createSelector2(getPlayers, getSelf,
    (List<Player> players, Player me) => players.where((Player p) => p.id != me.id).toList());

final Selector<GameModel, bool> amOwner =
    createSelector1(getRoom, (room) => room.owner == installId());

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
