import 'package:flutter/material.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

List<Widget> playerDecisions(Store<GameModel> store, Heist heist) {
  List<Widget> heistDecisions = [];
  heist.decisions.forEach((playerId, decision) {
    Player player = getPlayerById(store.state, playerId);
    List<Widget> children = [
      new Text(
        '${player.name} (${player.role}) ->',
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

Widget heistSummary(Store<GameModel> store, Heist heist, int pot) => new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      child: new Column(
        children: [
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            new Text('Heist ${heist.order}',
                style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            heist.wasSuccess
                ? const Text('SUCCESS',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green))
                : const Text('FAIL',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red)),
          ]),
          new Divider(),
          new Container(
            padding: paddingSmall,
            child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              new Text('Price: ${heist.price}', style: infoTextStyle),
              new Text('Pot: $pot', style: infoTextStyle),
            ]),
          ),
          new Column(
            children: playerDecisions(store, heist),
          ),
        ],
      ),
    ));

Widget winner(Score score) => new Card(
      elevation: 2.0,
      child: new Container(
        alignment: Alignment.center,
        padding: paddingMedium,
        child: new Column(
          children: [
            new Container(
                padding: paddingTitle,
                child: new Text('${score.winner} win!', style: titleTextStyle)),
            new Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              new Text(Team.THIEVES.toString(), style: infoTextStyle),
              new Text('${score.thiefScore} - ${score.agentScore}',
                  style: new TextStyle(fontSize: 32.0)),
              new Text(Team.AGENTS.toString(), style: infoTextStyle),
            ])
          ],
        ),
      ),
    );

// TODO: fix scrolling
Widget endgame(Store<GameModel> store) {
  List<Heist> heists = getHeists(store.state);
  Score score = calculateScore(heists);

  List<Widget> children = [
    winner(score),
  ];

  Map<String, List<Round>> rounds = getRounds(store.state);
  for (Heist heist in heists) {
    Round lastRound = rounds[heist.id].last;
    children.add(heistSummary(store, heist, lastRound.pot));
  }

  return new Column(
    children: children,
  );
}
