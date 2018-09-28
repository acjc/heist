import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/haunt_selectors.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

export 'bidding_selectors.dart';
export 'exclusion_selectors.dart';
export 'gifting_selectors.dart';
export 'haunt_selectors.dart';
export 'local_actions_selectors.dart';
export 'player_selectors.dart';
export 'round_selectors.dart';
export 'setup_selectors.dart';

final getRoom = (GameModel gameModel) => gameModel.room;
final getPlayers = (GameModel gameModel) => gameModel.players;
final getHaunts = (GameModel gameModel) => gameModel.haunts;
final getRounds = (GameModel gameModel) => gameModel.rounds;
final getPlayerInstallId = (GameModel gameModel) => gameModel.playerInstallId;
final getPlayerName = (GameModel gameModel) => gameModel.playerName;
final getRoomCode = (GameModel gameModel) => gameModel.roomCode;
final getBidAmount = (GameModel gameModel) => gameModel.bidAmount;
final getGiftAmount = (GameModel gameModel) => gameModel.giftAmount;
final getSubscriptions = (GameModel gameModel) => gameModel.subscriptions;
final getRequests = (GameModel gameModel) => gameModel.requests;
final getLocalActions = (GameModel gameModel) => gameModel.localActions;

bool requestInProcess(GameModel gameModel, Request request) =>
    getRequests(gameModel).contains(request);

Haunt hauntById(GameModel gameModel, String id) =>
    getHaunts(gameModel).singleWhere((h) => h.id == id);

// Reselect would not recognise changes to the current haunt
Haunt currentHaunt(GameModel gameModel) =>
    getHaunts(gameModel).firstWhere((h) => !h.complete, orElse: null);

Haunt previousHaunt(GameModel gameModel) =>
    hauntByOrder(gameModel, currentHaunt(gameModel).order - 1);

Haunt hauntByOrder(GameModel gameModel, int order) =>
    getHaunts(gameModel).singleWhere((h) => h.order == order, orElse: null);

Round lastRoundForHaunt(Room room, Map<String, List<Round>> rounds, Haunt haunt) {
  List<Round> roundsForHaunt = rounds[haunt.id];
  return hauntHasActiveRound(room, rounds, haunt)
      ? roundsForHaunt.lastWhere((r) => r.complete)
      : roundsForHaunt.firstWhere((r) => !r.complete);
}

final Selector<GameModel, Round> currentRound = createSelector3(
    getRoom,
    getRounds,
    currentHaunt,
    (Room room, Map<String, List<Round>> rounds, Haunt currentHaunt) =>
        lastRoundForHaunt(room, rounds, currentHaunt));

final Selector<GameModel, Round> previousRound = createSelector3(
    getRounds,
    currentHaunt,
    currentRound,
    (Map<String, List<Round>> rounds, Haunt currentHaunt, Round currentRound) =>
        roundByOrder(rounds, currentHaunt, currentRound.order - 1));

Round roundByOrder(Map<String, List<Round>> rounds, Haunt haunt, int order) =>
    rounds[haunt.id].singleWhere((r) => r.order == order, orElse: null);
