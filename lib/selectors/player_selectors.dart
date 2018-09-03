import 'dart:math';

import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/role.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

// Selectors do not seem to work if you ever return null
final getSelf = (GameModel gameModel) => getPlayers(gameModel)
    .singleWhere((p) => p.installId == getPlayerInstallId(gameModel), orElse: () => null);

final getPlayerByRoleId =
    (GameModel gameModel, String role) => getPlayers(gameModel).singleWhere((p) => p.role == role);

final getPlayerById =
    (GameModel gameModel, String id) => getPlayers(gameModel).singleWhere((p) => p.id == id);

final getPlayerByName =
    (GameModel gameModel, String name) => getPlayers(gameModel).singleWhere((p) => p.name == name);

final Selector<GameModel, List<Player>> getOtherPlayers = createSelector2(getPlayers, getSelf,
    (List<Player> players, Player me) => players.where((Player p) => p.id != me.id).toList());

final Selector<GameModel, bool> amOwner = createSelector2(
    getRoom, getPlayerInstallId, (Room room, String installId) => room.owner == installId);

final getKingpin = (GameModel gameModel) =>
    getPlayers(gameModel).singleWhere((p) => p.role == KINGPIN.roleId, orElse: null);

final Selector<GameModel, bool> haveGuessedKingpin = createSelector3(
    getSelf,
    getKingpin,
    getRoom,
    (Player me, Player kingpin, Room room) =>
        room.kingpinGuess != null &&
        room.kingpinGuess == kingpin.id &&
        me.role == LEAD_AGENT.roleId);

final Selector<GameModel, int> currentBalance = createSelector4(
    getPlayers,
    getSelf,
    getHeists,
    getRounds,
    (List<Player> players, Player me, List<Heist> heists, Map<String, List<Round>> rounds) =>
        calculateBalance(players, me, heists, rounds));

int calculateBalanceFromStore(Store<GameModel> store, Player player) => calculateBalance(
    getPlayers(store.state), player, getHeists(store.state), getRounds(store.state));

int calculateBalance(
    List<Player> players, Player player, List<Heist> heists, Map<String, List<Round>> allRounds) {
  if (players.isEmpty || player == null) {
    return 0;
  }
  int balance = player.initialBalance;
  if (allRounds.isEmpty) {
    return balance;
  }
  heists.forEach((heist) {
    List<Round> rounds = allRounds[heist.id];
    if (rounds != null && rounds.isNotEmpty) {
      balance = resolveBalanceForGifts(player.id, rounds, balance);

      Map<String, Bid> mostRecentBids = rounds.last.bids;
      if (heist.allDecided) {
        balance -= mostRecentBids[player.id].amount;
        balance = resolveBalanceForHeistOutcome(players, player, heist, rounds.last.pot, balance);
      } else if (hasProposedBid(player.id, mostRecentBids, players.length)) {
        balance -= mostRecentBids[player.id].amount;
      }
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

bool hasProposedBid(String playerId, Map<String, Bid> bids, int numPlayers) {
  return bids.length != numPlayers && bids.containsKey(playerId);
}

int resolveBalanceForHeistOutcome(
    List<Player> players, Player player, Heist heist, int pot, int balance) {
  Random random = new Random(heist.id.hashCode);

  int kingpinPayout = randomlySplit(random, pot, 2)[0];
  int leadAgentPayout = pot - kingpinPayout;
  if (player.role == KINGPIN.roleId) {
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
  return player.role == LEAD_AGENT.roleId && (steals == 0 || steals == 1 && playerStole);
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
