import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, bool> rolesAreAssigned = createSelector1(getPlayers,
    (List<Player> players) => players.every((p) => p.role != null && p.role.isNotEmpty));

final Selector<GameModel, bool> isNewGame = createSelector3(
    rolesAreAssigned,
    getHaunts,
    hasRounds,
    (bool rolesAreAssigned, List<Haunt> haunts, bool hasRounds) =>
        !rolesAreAssigned || haunts.length < 5 || !hasRounds);

final Selector<GameModel, bool> hasRounds = createSelector1(
    getRounds,
    (Map<String, List<Round>> rounds) =>
        rounds.length == 5 && rounds.values.expand((rs) => rs).length == 25);

final Selector<GameModel, bool> roomIsAvailable =
    createSelector1(getRoom, (Room room) => room.id != null);

final Selector<GameModel, bool> rolesSubmitted =
    createSelector2(roomIsAvailable, getRoom,
            (bool roomIsAvailable, Room room) => roomIsAvailable && room.rolesSubmitted);

final Selector<GameModel, bool> waitingForPlayers = createSelector2(
    getPlayers, getRoom, (List<Player> players, Room room) => players.length < room.numPlayers);

final Selector<GameModel, bool> gameIsReady = createSelector5(
    waitingForPlayers,
    isNewGame,
    getHaunts,
    hasRounds,
    rolesSubmitted,
    (
      bool waitingForPlayers,
      bool isNewGame,
      List<Haunt> haunts,
      bool hasRounds,
      bool rolesSubmitted,
    ) =>
        !waitingForPlayers && !isNewGame && haunts.length == 5 && hasRounds && rolesSubmitted);

final Selector<GameModel, bool> haveJoinedGame = createSelector2(
    getSelf, getRoom, (Player me, Room room) => me != null && me.room?.documentID == room.id);
