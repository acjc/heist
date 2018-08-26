import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

List<Widget> playerDecisions(BuildContext context, Store<GameModel> store, Heist heist) {
  List<Widget> heistDecisions = [];
  heist.decisions.forEach((playerId, decision) {
    Player player = getPlayerById(store.state, playerId);
    List<Widget> children = [
      new Text(
        AppLocalizations.of(context).playerRole(player.name, getRoleDisplayName(player.role)),
        style: infoTextStyle,
      ),
    ];
    children.add(new Text(' $decision',
        style: new TextStyle(
          fontSize: 16.0,
          color: decisionColour(decision),
          fontWeight: FontWeight.bold,
        )));
    heistDecisions.add(new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    ));
  });
  return heistDecisions;
}

Widget heistSummary(BuildContext context, Store<GameModel> store, Heist heist, int pot) => new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      child: new Column(
        children: [
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            new Text(AppLocalizations.of(context).heistTitle(heist.order),
                style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            heist.wasSuccess
                ? Text(AppLocalizations.of(context).success.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green))
                : Text(AppLocalizations.of(context).fail.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red)),
          ]),
          new Divider(),
          new Container(
            padding: paddingSmall,
            child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              new Text(AppLocalizations.of(context).heistPrice(heist.price), style: infoTextStyle),
              new Text(AppLocalizations.of(context).heistPot(pot), style: infoTextStyle),
            ]),
          ),
          new Column(
            children: playerDecisions(context, store, heist),
          ),
        ],
      ),
    ));

Widget winner(BuildContext context, Score score) => new Card(
      elevation: 2.0,
      child: new Container(
        alignment: Alignment.center,
        padding: paddingMedium,
        child: new Column(
          children: [
            new Container(
                padding: paddingTitle,
                child: new Text(
                    AppLocalizations.of(context).winner(score.winner.toString()),
                    style: titleTextStyle)),
            new Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              new Text(Team.THIEVES.toString(), style: infoTextStyle),
              new Text(AppLocalizations.of(context).teamScores(score.thiefScore, score.agentScore),
                  style: new TextStyle(fontSize: 32.0)),
              new Text(Team.AGENTS.toString(), style: infoTextStyle),
            ])
          ],
        ),
      ),
    );

Widget endgame(BuildContext context, Store<GameModel> store) {
  List<Heist> heists = getHeists(store.state);
  Score score = calculateScore(heists);

  List<Widget> children = [
    winner(context, score),
  ];

  Map<String, List<Round>> rounds = getRounds(store.state);
  for (Heist heist in heists) {
    Round lastRound = rounds[heist.id].last;
    children.add(heistSummary(context, store, heist, lastRound.pot));
  }

  return new ListView(
    children: children,
  );
}
