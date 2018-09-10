import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/round_end_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget roundContinueButton(Store<GameModel> store) => new StoreConnector<GameModel, bool>(
    converter: (store) => requestInProcess(store.state, Request.CompletingRound),
    distinct: true,
    builder: (context, completingGame) {
      return new Container(
        padding: paddingSmall,
        child: new RaisedButton(
          child: new Text(AppLocalizations.of(context).continueButton, style: buttonTextStyle),
          onPressed: completingGame ? null : () => store.dispatch(new CompleteRoundAction()),
        ),
      );
    });

Widget roundEnd(BuildContext context, Store<GameModel> store) {
  List<Player> players = getPlayers(store.state);
  Round round = currentRound(store.state);
  assert(players.length == round.bids.length);

  List<Widget> children = new List.generate(players.length, (i) {
    Player player = players[i];
    return new Container(
      padding: paddingSmall,
      child: new Text(
          AppLocalizations.of(context).playerBid(player.name, round.bids[player.id].amount),
          style: infoTextStyle),
    );
  })
    ..add(
      new Container(
          padding: paddingSmall,
          child: new Text(
              AppLocalizations.of(context).totalPot(round.pot, currentHaunt(store.state).price),
              style: titleTextStyle)),
    );

  if (amOwner(store.state)) {
    children.add(roundContinueButton(store));
  }

  return new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    ),
  );
}
