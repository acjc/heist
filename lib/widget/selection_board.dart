import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

Widget selectionBoard(Store<GameModel> store) => StoreConnector<GameModel, Set<Player>>(
    converter: (store) => currentTeam(store.state),
    distinct: true,
    builder: (context, team) {
      List<Player> players = getPlayers(store.state);
      Player leader = currentLeader(store.state);
      return TitledCard(
        title: AppLocalizations.of(context).team,
        child: Container(
            padding: paddingMedium,
            child: TeamGridView(selectionBoardChildren(context, players, team, leader))),
      );
    });

List<Widget> selectionBoardChildren(
        BuildContext context, List<Player> players, Set<Player> team, Player leader) =>
    List.generate(players.length, (i) {
      Player player = players[i];
      bool isInTeam = team.contains(player);
      bool isLeader = player.id == leader.id;
      return playerTile(context, player.name, isInTeam, isLeader);
    });

Widget playerTileText(BuildContext context, String playerName, bool isInTeam, bool isLeader) {
  Color color = Theme.of(context).brightness == Brightness.light
      ? (isInTeam ? Colors.white : Theme.of(context).textTheme.body1.color)
      : (isInTeam ? Colors.black87 : Theme.of(context).textTheme.body1.color);
  Text text = Text(playerName, style: TextStyle(color: color, fontSize: 16.0));
  if (isLeader) {
    return iconText(Icon(Icons.star, color: color), text);
  }
  return text;
}

Widget playerTile(BuildContext context, String playerName, bool isInTeam, bool isLeader) {
  Color backgroundColor = Theme.of(context).primaryColor;
  return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: backgroundColor),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: isInTeam ? tileShadow : null,
        color: isInTeam ? backgroundColor : null,
      ),
      child: playerTileText(context, playerName, isInTeam, isLeader));
}
