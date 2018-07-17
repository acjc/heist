part of heist;

final getRoom = (GameModel gameModel) => gameModel.room;
final getPlayers = (GameModel gameModel) => gameModel.players;
final getHeists = (GameModel gameModel) => gameModel.heists;
final getRounds = (GameModel gameModel) => gameModel.rounds;
final getPlayerInstallId = (GameModel gameModel) => gameModel.playerInstallId;
final getPlayerName = (GameModel gameModel) => gameModel.playerName;
final getBidAmount = (GameModel gameModel) => gameModel.bidAmount;
final getGiftAmount = (GameModel gameModel) => gameModel.giftAmount;
final getRequests = (GameModel gameModel) => gameModel.requests;

bool requestInProcess(GameModel gameModel, Request request) =>
    getRequests(gameModel).contains(request);

// Reselect would not recognise changes to the current heist
final currentHeist = (GameModel gameModel) => getHeists(gameModel).last;

final Selector<GameModel, Round> currentRound = createSelector2(
    currentHeist, getRounds, (currentHeist, rounds) => rounds[currentHeist.id].last);
