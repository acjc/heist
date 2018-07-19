import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> isMyGo = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.leader == me.id);

final Selector<GameModel, Player> roundLeader = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) =>
        players.singleWhere((Player p) => p.id == currentRound.leader));

final Selector<GameModel, Set<Player>> playersInTeam = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) => players.where((Player p) {
          // Reselect needed this bool explicitly typed
          bool playerInTeam = currentRound.team.contains(p.id);
          return playerInTeam;
        }).toSet());

// Reselect could not handle Set<String>
final teamNames =
    (GameModel gameModel) => playersInTeam(gameModel).map((Player p) => p.name).toSet();

// Reselect could not handle Set<String>
final teamIds = (GameModel gameModel) => playersInTeam(gameModel).map((Player p) => p.id).toSet();
