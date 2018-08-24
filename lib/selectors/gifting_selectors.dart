import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, Gift> myCurrentGift = createSelector2(
    currentRound, getSelf, (Round currentRound, Player me) => currentRound.gifts[me.id]);

final Selector<GameModel, bool> haveReceivedGiftThisRound = createSelector2(currentRound, getSelf,
    (Round currentRound, Player me) => currentRound.gifts.values.any((g) => g.recipient == me.id));
