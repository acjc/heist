import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> isMyGo = createSelector2(
    currentLeader, getSelf, (Player currentLeader, Player me) => currentLeader.id == me.id);

int playerLedRoundsForHaunt(Map<String, List<Round>> rounds, Haunt haunt) =>
    rounds[haunt.id].where((r) => r.wasPlayerLed).length;

int playerLedRoundsUpTo(List<Haunt> haunts, Map<String, List<Round>> rounds, Round round) {
  Haunt haunt = haunts.singleWhere((h) => h.id == round.haunt);
  int roundsSoFar = haunts
      .where((h) => h.order < haunt.order)
      .fold(0, (value, h) => value + playerLedRoundsForHaunt(rounds, h));
  roundsSoFar += rounds[haunt.id].where((r) => r.wasPlayerLed && r.order <= round.order).length;
  return roundsSoFar;
}

final Selector<GameModel, int> playerLedRoundsSoFar = createSelector3(
    getHaunts,
    getRounds,
    currentRound,
    (List<Haunt> haunts, Map<String, List<Round>> rounds, Round currentRound) =>
        playerLedRoundsUpTo(haunts, rounds, currentRound));

final Selector<GameModel, Player> currentLeader =
    createSelector2(getPlayers, playerLedRoundsSoFar, (List<Player> players, int roundsSoFar) {
  int leaderOrder = (roundsSoFar % players.length) + 1;
  return players.singleWhere((Player p) => p.order == leaderOrder);
});

Player leaderForRound(GameModel gameModel, Round round) {
  List<Player> players = getPlayers(gameModel);
  int roundsSoFar = playerLedRoundsUpTo(getHaunts(gameModel), getRounds(gameModel), round);
  int leaderOrder = (roundsSoFar % players.length) + 1;
  return players.singleWhere((Player p) => p.order == leaderOrder);
}

class BidTotal {
  final String playerId;
  final int amount;

  BidTotal._(this.playerId, this.amount);
}

List<BidTotal> bidTotalsForRound(Round round) {
  Map<String, int> bidTotalsPerPlayer = {};
  round.bids.forEach((String playerId, Bid bid) {
    bidTotalsPerPlayer.update(
      bid.recipient,
      (currentValue) => currentValue + bid.amount,
      ifAbsent: () => bid.amount,
    );
  });
  List<BidTotal> bidTotals = [];
  bidTotalsPerPlayer.forEach((String recipient, int totalBid) {
    bidTotals.add(BidTotal._(recipient, totalBid));
  });
  bidTotals.sort((bt1, bt2) => bt1.amount.compareTo(bt2.amount));
  return bidTotals;
}

List<Player> winnersForRound(List<Player> players, Haunt haunt, Round round) {
  List<BidTotal> bidTotals = bidTotalsForRound(round);
  if (bidTotals.length < haunt.numPlayers) {
    return [];
  }
  return bidTotals
      .sublist(0, haunt.numPlayers)
      .map((bt) => players.singleWhere((p) => p.id == bt.playerId))
      .toList();
}

int potForRound(Haunt haunt, Round round) {
  return bidTotalsForRound(round)
      .sublist(0, haunt.numPlayers)
      .fold(0, (int value, BidTotal bidTotal) => value + bidTotal.amount);
}

Map<String, Bid> bidsOnMeForRound(GameModel gameModel, Round round) {
  String myId = getSelf(gameModel).id;
  Map<String, Bid> bids = Map.of(round.bids);
  bids.removeWhere((bidder, bid) => bid.recipient != myId);
  return bids;
}

final Selector<GameModel, List<Player>> currentTeam = createSelector3(
    getPlayers,
    currentHaunt,
    currentRound,
    (List<Player> players, Haunt currentHaunt, Round currentRound) =>
        winnersForRound(players, currentHaunt, currentRound));

final Selector<GameModel, int> currentPot = createSelector2(currentHaunt, currentRound,
    (Haunt currentHaunt, Round currentRound) => potForRound(currentHaunt, currentRound));

final Selector<GameModel, bool> goingOnHaunt = createSelector2(
    currentTeam, getSelf, (List<Player> currentTeam, Player me) => currentTeam.contains(me));
