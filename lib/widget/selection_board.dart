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
                      currentHeist(store.state).numPlayers,
                    ),
                    style: titleTextStyle),
              ),
              new HeistGridView(selectionBoardChildren(context, players, team, leader)),
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

Widget playerTileText(String playerName, bool isInTeam, bool isLeader) {
  Color textColor = isInTeam ? Colors.white : Colors.black87;
  Text text = new Text(
    playerName,
    style: new TextStyle(
      color: textColor,
      fontSize: 16.0,
    ),
  );
  if (isLeader) {
    return iconText(new Icon(Icons.star, color: textColor), text);
  }
  return text;
}

Widget playerTile(BuildContext context, String playerName, bool isInTeam, bool isLeader) {
  Color backgroundColor = Theme.of(context).accentColor;
  return new Container(
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        border: new Border.all(color: backgroundColor),
        borderRadius: BorderRadius.circular(5.0),
        color: isInTeam ? backgroundColor : null,
      ),
      child: playerTileText(playerName, isInTeam, isLeader));
}
