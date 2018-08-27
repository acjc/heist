import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';
import 'team_picker.dart';

Widget waitForTeam(Store<GameModel> store) => new Column(children: [
      roundTitle(store),
      new Card(
          elevation: 2.0,
          child: new Container(
              padding: paddingLarge,
              child: centeredMessage('${roundLeader(store.state).name} is picking a team...'))),
      selectionBoard(store),
    ]);

Widget selectionBoard(Store<GameModel> store) => new StoreConnector<GameModel, Set<String>>(
    converter: (store) => teamNames(store.state),
    distinct: true,
    builder: (context, teamNames) {
      List<Player> players = getPlayers(store.state);
      return new Card(
        elevation: 2.0,
        child: new Container(
            padding: paddingMedium,
            child: new Column(children: [
              new Container(
                padding: paddingTitle,
                child: new Text(
                    'TEAM (${teamNames.length} / ${currentHeist(store.state).numPlayers})',
                    style: titleTextStyle),
              ),
              new HeistGridView(selectionBoardChildren(context, players, teamNames)),
            ])),
      );
    });

List<Widget> selectionBoardChildren(
    BuildContext context, List<Player> players, Set<String> teamNames) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(players.length, (i) {
    Player player = players[i];
    bool isInTeam = teamNames.contains(player.name);
    return playerTile(player.name, isInTeam, color);
  });
}
