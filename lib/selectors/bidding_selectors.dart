import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, Set<Player>> bidders = createSelector2(
    getPlayers,
    currentRound,
    (List<Player> players, Round currentRound) =>
        players.where((Player p) => currentRound.bids[p.id] != null).toSet());

final Selector<GameModel, Set<String>> bidderNames =
    createSelector1(bidders, (Set<Player> bidders) => bidders.map((Player p) => p.name).toSet());

final Selector<GameModel, bool> biddingComplete = createSelector2(
    bidders, getRoom, (Set<Player> bidders, Room room) => bidders.length == room.numPlayers);

final Selector<GameModel, Bid> myCurrentBid =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.bids[me.id]);

final isAuction = (GameModel gameModel) => currentRound(gameModel).isAuction;
