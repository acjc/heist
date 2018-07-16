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

final Selector<GameModel, int> currentBalance = createSelector4(
    getPlayers,
    getSelf,
    getHeists,
    getRounds,
    (List<Player> players, Player me, List<Heist> heists, Map<String, List<Round>> allRounds) =>
        calculateBalance(players, me, heists, allRounds));

int calculateBalanceFromStore(Store<GameModel> store, Player player) => calculateBalance(
      getPlayers(store.state), player, getHeists(store.state), getRounds(store.state));

int calculateBalance(
    List<Player> players, Player player, List<Heist> heists, Map<String, List<Round>> allRounds) {
  int balance = player.initialBalance;
  heists.forEach((heist) {
    List<Round> rounds = allRounds[heist.id];

    balance = resolveBalanceForGifts(player.id, rounds, balance);

    if (heist.allDecided) {
      balance -= rounds.last.bids[player.id].amount;
      int pot = rounds.last.pot;
      balance = resolveBalanceForHeistOutcome(players, player, heist, pot, balance);
    }
  });
  assert(balance >= 0);
  return balance;
}

int resolveBalanceForGifts(String playerId, List<Round> rounds, int balance) {
  rounds.forEach((round) => round.gifts.forEach((id, gift) {
        if (id == playerId) {
          balance -= gift.amount;
        } else if (gift.recipient == playerId) {
          balance += gift.amount;
        }
      }));
  return balance;
}

int resolveBalanceForHeistOutcome(
    List<Player> players, Player player, Heist heist, int pot, int balance) {
  Random random = new Random(heist.id.hashCode);
  int kingpinPayout = randomlySplit(random, pot, 2)[0];
  int leadAgentPayout = pot - kingpinPayout;
  if (player.role == 'KINGPIN') {
    balance += kingpinPayout;
  }
  int steals = heist.decisions.values.where((d) => d == Steal).length;
  bool playerStole = heist.decisions[player.id] == Steal;
  if (shouldPayoutLeadAgent(player, playerStole, steals)) {
    balance += leadAgentPayout;
  } else if (steals > 0 && playerStole) {
    List<Player> playersWhoStole = players.where((p) => heist.decisions[p.id] == Steal).toList();
    balance += randomlySplit(random, leadAgentPayout, steals)[playersWhoStole.indexOf(player)];
  }
  return balance;
}

bool shouldPayoutLeadAgent(Player player, bool playerStole, int steals) {
  return player.role == 'LEAD_AGENT' && (steals == 0 || steals == 1 && playerStole);
}

/// Split a number into approximately equal integer portions, using the given RNG to assign remainders.
List<int> randomlySplit(Random random, int n, int ways) {
  assert(n >= 0);
  assert(ways > 0);

  int remainder = n % ways;
  bool splitsEvenly = remainder == 0;
  double portion = n / ways;
  if (splitsEvenly) {
    return new List.generate(ways, (i) => portion.round());
  }
  List<int> ceilIndices = new List.generate(ways, (i) => i);
  ceilIndices.shuffle(random);
  return new List.generate(ways, (i) {
    return ceilIndices.indexOf(i) < remainder ? portion.ceil() : portion.floor();
  });
}