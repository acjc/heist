import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';
import 'team_picker.dart';

Widget waitForTeamMessage(bool goingOnHeist, String leaderName) {
  const TextStyle defaultTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
  if (goingOnHeist) {
    return new RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        style: defaultTextStyle,
        children: [
          new TextSpan(text: leaderName, style: boldTextStyle),
          new TextSpan(text: ' picked you in the team!'),
        ],
      ),
    );
  }

  return new Column(
    children: [
      new Padding(
        padding: paddingSmall,
        child: new Text("You haven't been picked!", style: infoTextStyle),
      ),
      new RichText(
        textAlign: TextAlign.center,
        text: new TextSpan(
          style: defaultTextStyle,
          children: [
            new TextSpan(text: "Convince "),
            new TextSpan(text: leaderName, style: boldTextStyle),
            new TextSpan(text: ' to put you in the team!'),
          ],
        ),
      ),
    ],
  );
}

Widget waitForTeam(BuildContext context, Store<GameModel> store) {
  return new StoreConnector<GameModel, bool>(
    distinct: true,
    converter: (store) => goingOnHeist(store.state),
    builder: (context, goingOnHeist) {
      Player leader = currentLeader(store.state);
      return new Container(
        color: goingOnHeist ? Colors.teal : Colors.redAccent,
        padding: paddingLarge,
        child: new Card(
          elevation: 6.0,
          child: new Padding(
            padding: paddingSmall,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                goingOnHeist
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 250.0)
                    : const Icon(Icons.do_not_disturb_alt, color: Colors.red, size: 250.0),
                waitForTeamMessage(goingOnHeist, leader.name),
                new Column(
                  children: [
                    new Divider(),
                    roundTitleContents(context, store),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget selectionBoard(Store<GameModel> store) => new StoreConnector<GameModel, Set<Player>>(
    converter: (store) => currentTeam(store.state),
    distinct: true,
    builder: (context, team) {
      List<Player> players = getPlayers(store.state);
      Player leader = currentLeader(store.state);
      return new Card(
        elevation: 2.0,
        child: new Container(
            padding: paddingMedium,
            child: new Column(children: [
              new Container(
                padding: paddingTitle,
                child: new Text(
                    AppLocalizations.of(context).pickedTeamSize(
                      team.length,
                      currentHeist(store.state).numPlayers,
                    ),
                    style: titleTextStyle),
              ),
              new HeistGridView(selectionBoardChildren(context, players, team, leader)),
            ])),
      );
    });

List<Widget> selectionBoardChildren(
    BuildContext context, List<Player> players, Set<Player> team, Player leader) {
  return new List.generate(players.length, (i) {
    Player player = players[i];
    bool isInTeam = team.contains(player);
    bool isLeader = player.id == leader.id;
    return playerTile(context, player.name, isInTeam, isLeader);
  });
}
