part of heist;

final Selector<GameModel, bool> rolesAreAssigned =
    createSelector1(getPlayers, (players) => players.any((p) => p.role == null || p.role.isEmpty));

final Selector<GameModel, bool> isNewGame = createSelector3(rolesAreAssigned, getHeists, hasRounds,
    (rolesAreAssigned, heists, hasRounds) => rolesAreAssigned || heists.isEmpty || !hasRounds);

final Selector<GameModel, bool> hasRounds = createSelector1(getRounds,
    (rounds) => rounds.isNotEmpty && rounds.values.any((List<Round> rs) => rs.isNotEmpty));

final Selector<GameModel, bool> roomIsAvailable =
    createSelector1(getRoom, (room) => room.id != null);

final Selector<GameModel, bool> waitingForPlayers =
    createSelector2(getPlayers, getRoom, (players, room) => players.length < room.numPlayers);

final Selector<GameModel, bool> gameIsReady = createSelector5(
    roomIsAvailable,
    waitingForPlayers,
    isNewGame,
    getHeists,
    hasRounds,
    (roomIsAvailable, waitingForPlayers, isNewGame, heists, hasRounds) =>
        roomIsAvailable && !waitingForPlayers && !isNewGame && heists.isNotEmpty && hasRounds);

final Selector<GameModel, bool> haveJoinedGame =
    createSelector2(getSelf, getRoom, (me, room) => me != null && me.room?.documentID == room.id);
