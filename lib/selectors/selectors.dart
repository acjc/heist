import 'package:heist/db/database_model.dart';
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

final Selector<GameModel, Round> currentRound = createSelector2(
    currentHaunt,
    getRounds,
    (Haunt currentHaunt, Map<String, List<Round>> rounds) =>
        rounds[currentHaunt.id].firstWhere((r) => !r.complete));

Round lastRoundForHaunt(GameModel gameModel, Haunt haunt) {
  List<Round> rounds = getRounds(gameModel)[haunt.id];
  return haunt.complete
      ? rounds.lastWhere((r) => r.complete)
      : rounds.firstWhere((r) => !r.complete);
}

final Selector<GameModel, Round> previousRound = createSelector3(
    currentHaunt,
    getRounds,
    currentRound,
    (Haunt currentHaunt, Map<String, List<Round>> rounds, Round currentRound) =>
        roundByOrder(currentHaunt, rounds, currentRound.order - 1));

Round roundByOrder(Haunt haunt, Map<String, List<Round>> rounds, int order) =>
    rounds[haunt.id].singleWhere((r) => r.order == order);
