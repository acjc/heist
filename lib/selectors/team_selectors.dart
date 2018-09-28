import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

class BidTotal {
  final String playerId;
  final int amount;

  BidTotal._(this.playerId, this.amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidTotal &&
          runtimeType == other.runtimeType &&
          playerId == other.playerId &&
          amount == other.amount;

  @override
  int get hashCode => playerId.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'BidTotal{playerId: $playerId, amount: $amount}';
  }
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
  List<BidTotal> bidTotals = bidTotalsForRound(round);
  if (bidTotals.length < haunt.numPlayers) {
    return -1;
  }
  return bidTotals
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

final Selector<GameModel, bool> goingOnHaunt = createSelector2(
    currentTeam, getSelf, (List<Player> currentTeam, Player me) => currentTeam.contains(me));
