import 'package:heist/db/database_model.dart';
import 'package:heist/state.dart';
import 'package:reselect/reselect.dart';

import 'selectors.dart';

final Selector<GameModel, Gift> myCurrentGift =
    createSelector2(currentRound, getSelf, (currentRound, me) => currentRound.gifts[me.id]);
