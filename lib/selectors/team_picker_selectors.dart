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

final Selector<GameModel, Set<Player>> currentTeam = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) => players.where((Player p) {
          // Reselect needed this bool explicitly typed
          bool playerInTeam = currentRound.team.contains(p.id);
          return playerInTeam;
        }).toSet());

final Selector<GameModel, bool> currentTeamIsFull = createSelector2(currentHaunt, currentTeam,
    (Haunt currentHaunt, Set<Player> currentTeam) => currentHaunt.numPlayers == currentTeam.length);

final teamForRound = (GameModel gameModel, Round round) =>
    getPlayers(gameModel).where((p) => round.team.contains(p.id)).toSet();
