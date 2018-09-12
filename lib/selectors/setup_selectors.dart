import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> rolesAreAssigned = createSelector1(getPlayers,
    (List<Player> players) => players.every((p) => p.role != null && p.role.isNotEmpty));

final Selector<GameModel, bool> isNewGame = createSelector3(rolesAreAssigned, getHaunts, hasRounds,
    (rolesAreAssigned, haunts, hasRounds) => !rolesAreAssigned || haunts.isEmpty || !hasRounds);

final Selector<GameModel, bool> hasRounds = createSelector1(getRounds,
    (rounds) => rounds.isNotEmpty && rounds.values.any((List<Round> rs) => rs.isNotEmpty));

final Selector<GameModel, bool> roomIsAvailable =
    createSelector1(getRoom, (Room room) => room.id != null);

final Selector<GameModel, bool> waitingForPlayers = createSelector2(
    getPlayers, getRoom, (List<Player> players, Room room) => players.length < room.numPlayers);

final Selector<GameModel, bool> gameIsReady = createSelector5(
    roomIsAvailable,
    waitingForPlayers,
    isNewGame,
    getHaunts,
    hasRounds,
    (roomIsAvailable, waitingForPlayers, isNewGame, haunts, hasRounds) =>
        roomIsAvailable && !waitingForPlayers && !isNewGame && haunts.isNotEmpty && hasRounds);

final Selector<GameModel, bool> haveJoinedGame =
    createSelector2(getSelf, getRoom, (me, room) => me != null && me.room?.documentID == room.id);
