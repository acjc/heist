import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

List<Widget> playerDecisions(BuildContext context, Store<GameModel> store, Haunt heist) {
  List<Widget> heistDecisions = [];
  heist.decisions.forEach((playerId, decision) {
    Player player = getPlayerById(store.state, playerId);
    heistDecisions.add(
      new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text('${player.name}:', style: infoTextStyle),
          new Text(
            ' $decision',
            style: new TextStyle(
              fontSize: 16.0,
              color: decisionColour(decision),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  });
  return heistDecisions;
}

Text heistResultText(BuildContext context, bool wasSuccess) {
  return wasSuccess
      ? new Text(
          AppLocalizations.of(context).success.toUpperCase(),
          style: const TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: HeistColors.green),
        )
      : new Text(
          AppLocalizations.of(context).fail.toUpperCase(),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
        );
}

Widget heistSummary(BuildContext context, Store<GameModel> store, Haunt heist, int pot) => new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      child: new Column(
        children: [
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            new Text(AppLocalizations.of(context).hauntTitle(heist.order), style: boldTextStyle),
            heistResultText(context, heist.wasSuccess),
          ]),
          new Divider(),
          new Container(
            padding: paddingSmall,
            child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              new Text(AppLocalizations.of(context).hauntPrice(heist.price), style: infoTextStyle),
              new Text(AppLocalizations.of(context).hauntPot(pot), style: infoTextStyle),
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
                child: new Text(AppLocalizations.of(context).winner(score.winner.toString()),
                    style: titleTextStyle)),
            new Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              new Text(Team.SCARY.toString(), style: infoTextStyle),
              new Text(
                  AppLocalizations.of(context).teamScores(score.scaryScore, score.friendlyScore),
                  style: new TextStyle(fontSize: 32.0)),
              new Text(Team.FRIENDLY.toString(), style: infoTextStyle),
            ])
          ],
        ),
      ),
    );

Widget fullPlayerListForTeam(BuildContext context, List<Player> players, Team team, Color color) {
  List<Player> playersInTeam = players.where((p) => Roles.getTeam(p.role) == team).toList();
  return new Column(
    children: new List.generate(playersInTeam.length + 1, (i) {
      Player player = playersInTeam[0];
      return new Padding(
        padding: paddingBelowText,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Text(
              player.name,
              style: infoTextStyle,
            ),
            new Text(
              Roles.getRoleDisplayName(context, player.role),
              style: new TextStyle(color: color),
            ),
          ],
        ),
      );
    }),
  );
}

Widget fullPlayerList(BuildContext context, Store<GameModel> store) {
  List<Player> players = getPlayers(store.state);
  return new Card(
    elevation: 2.0,
    child: new Padding(
      padding: paddingMedium,
      child: new Column(children: [
        new Padding(
          padding: paddingTitle,
          child: new Text(AppLocalizations.of(context).players, style: titleTextStyle),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            fullPlayerListForTeam(context, players, Team.SCARY, Colors.pink),
            fullPlayerListForTeam(context, players, Team.FRIENDLY, Colors.purple),
          ],
        )
      ]),
    ),
  );
}

Widget endgame(BuildContext context, Store<GameModel> store) {
  List<Haunt> heists = getHaunts(store.state);
  Score score = calculateScore(heists);

  List<Widget> children = [
    winner(context, score),
    fullPlayerList(context, store),
  ];

  Map<String, List<Round>> rounds = getRounds(store.state);
  for (Haunt heist in heists) {
    Round lastRound = rounds[heist.id].last;
    children.add(heistSummary(context, store, heist, lastRound.pot));
  }

  return new ListView(
    children: children,
  );
}
