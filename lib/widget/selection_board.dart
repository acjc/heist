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
              child: centeredMessage('${currentLeader(store.state).name} is picking a team...'))),
      selectionBoard(store),
    ]);

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
                child: new Text('TEAM (${team.length} / ${currentHeist(store.state).numPlayers})',
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
