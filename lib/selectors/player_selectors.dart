import 'dart:math';

import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
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

final getBrenda = (GameModel gameModel) =>
    getPlayers(gameModel).singleWhere((p) => p.role == Roles.brenda.roleId, orElse: null);

final Selector<GameModel, bool> haveGuessedBrenda = createSelector3(
    getSelf,
    getBrenda,
    getRoom,
    (Player me, Player brenda, Room room) =>
        room.brendaGuess != null &&
        room.brendaGuess == brenda.id &&
        me.role == Roles.bertie.roleId);

final Selector<GameModel, int> currentBalance = createSelector4(
    getPlayers,
    getSelf,
    getHaunts,
    getRounds,
    (List<Player> players, Player me, List<Haunt> haunts, Map<String, List<Round>> rounds) =>
        calculateBalance(players, me, haunts, rounds));

int calculateBalanceFromStore(Store<GameModel> store, Player player) => calculateBalance(
    getPlayers(store.state), player, getHaunts(store.state), getRounds(store.state));

int calculateBalance(
    List<Player> players, Player player, List<Haunt> haunts, Map<String, List<Round>> allRounds) {
  if (players.isEmpty || player == null) {
    return 0;
  }
  int balance = player.initialBalance;
  if (allRounds.isEmpty) {
    return balance;
  }
  haunts.forEach((haunt) {
    List<Round> rounds = allRounds[haunt.id];
    if (rounds != null && rounds.isNotEmpty) {
      balance = resolveBalanceForGifts(player.id, rounds, balance);

      Map<String, Bid> mostRecentBids = rounds.last.bids;
      if (haunt.allDecided) {
        balance -= mostRecentBids[player.id].amount;
        balance = resolveBalanceForHauntOutcome(players, player, haunt, rounds.last.pot, balance);
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

Random newRandomForHaunt(Haunt haunt) {
  return new Random(haunt.id.hashCode);
}

int calculateBrendaPayout(Random random, int pot) {
  return randomlySplit(random, pot, 2)[0];
}

bool hasProposedBid(String playerId, Map<String, Bid> bids, int numPlayers) {
  return bids.length != numPlayers && bids.containsKey(playerId);
}

int resolveBalanceForHauntOutcome(
    List<Player> players, Player player, Haunt haunt, int pot, int balance) {
  Random random = newRandomForHaunt(haunt);

  int brendaPayout = calculateBrendaPayout(random, pot);
  int bertiePayout = pot - brendaPayout;
  if (player.role == Roles.brenda.roleId) {
    balance += brendaPayout;
  }

  bool playerStole = haunt.decisions[player.id] == Steal;
  if (player.role == Roles.bertie.roleId || playerStole) {
    List<Player> playersToReceive = players
        .where((p) => haunt.decisions[p.id] == Steal || p.role == Roles.bertie.roleId)
        .toList();
    List<int> split = randomlySplit(random, bertiePayout, playersToReceive.length);
    balance += split[playersToReceive.indexOf(player)];
  }
  return balance;
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
