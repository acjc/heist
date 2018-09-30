import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

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
                      currentHaunt(store.state).numPlayers,
                    ),
                    style: titleTextStyle),
              ),
              new TeamGridView(selectionBoardChildren(context, players, team, leader)),
            ])),
      );
    });

List<Widget> selectionBoardChildren(
        BuildContext context, List<Player> players, Set<Player> team, Player leader) =>
    new List.generate(players.length, (i) {
      Player player = players[i];
      bool isInTeam = team.contains(player);
      bool isLeader = player.id == leader.id;
      return playerTile(context, player.name, isInTeam, isLeader);
    });

Widget playerTileText(BuildContext context, String playerName, bool isInTeam, bool isLeader) {
  Color iconColor = isInTeam
      ? Colors.white
      : (Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).primaryColor
          : Colors.white);
  TextStyle textStyle = isInTeam ? TextStyle(color: Colors.white, fontSize: 16.0) : null;
  Text text = Text(playerName, style: textStyle);
  if (isLeader) {
    return iconText(Icon(Icons.star, color: iconColor), text);
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
