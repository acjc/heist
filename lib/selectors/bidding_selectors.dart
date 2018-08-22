import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, int> numBids = createSelector1(
    currentRound, (currentRound) => currentRound.bids.values.where((b) => b != null).length);

final Selector<GameModel, bool> biddingComplete =
    createSelector2(numBids, getRoom, (numBids, room) => numBids == room.numPlayers);

final Selector<GameModel, Bid> myCurrentBid =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.bids[me.id]);

final isAuction = (GameModel gameModel) => currentRound(gameModel).isAuction;
