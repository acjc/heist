import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> isMyGo = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.leader == me.id);

final Selector<GameModel, Player> currentLeader = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) =>
        players.singleWhere((Player p) => p.id == currentRound.leader));

final leaderForRound = (GameModel gameModel, Round round) =>
    getPlayers(gameModel).singleWhere((p) => p.id == round.leader);

final Selector<GameModel, Set<Player>> currentTeam = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) => players.where((Player p) {
          // Reselect needed this bool explicitly typed
          bool playerInTeam = currentRound.team.contains(p.id);
          return playerInTeam;
        }).toSet());

final teamForRound = (GameModel gameModel, Round round) =>
    getPlayers(gameModel).where((p) => round.team.contains(p.id)).toSet();
