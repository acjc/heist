import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, Set<Player>> currentExclusions = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) =>
        players.where((Player p) => currentRound.team.contains(p.id)).toSet());

final Selector<GameModel, bool> allExclusionsPicked = createSelector2(
    currentHaunt,
    currentExclusions,
    (Haunt currentHaunt, Set<Player> currentExclusions) =>
        currentHaunt.numPlayers == currentExclusions.length);

Set<Player> exclusionsForRound(GameModel gameModel, Round round) =>
    getPlayers(gameModel).where((p) => round.team.contains(p.id)).toSet();

final Selector<GameModel, bool> haveBeenExcluded = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.team.contains(me.id));

final Selector<GameModel, Set<Player>> currentInclusions = createSelector2(
    getPlayers,
    currentExclusions,
    (List<Player> players, Set<Player> currentExclusions) =>
        players.where((p) => !currentExclusions.contains(p)).toSet());
