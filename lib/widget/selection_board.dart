import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

Widget selectionBoard(Store<GameModel> store) => StoreConnector<GameModel, Set<Player>>(
    converter: (store) => currentExclusions(store.state),
    distinct: true,
    builder: (context, exclusions) {
      List<Player> players = getPlayers(store.state);
      Player leader = currentLeader(store.state);
      return Card(
        elevation: 2.0,
        child: Padding(
            padding: paddingMedium,
            child: Column(children: [
              Container(
                padding: paddingTitle,
                child: Text(
                    AppLocalizations.of(context).exclusionsSize(
                      exclusions.length,
                      getRoom(store.state).numExclusions,
                    ),
                    style: titleTextStyle),
              ),
              TeamGridView(selectionBoardChildren(context, players, exclusions, leader)),
            ])),
      );
    });

List<Widget> selectionBoardChildren(
        BuildContext context, List<Player> players, Set<Player> team, Player leader) =>
    List.generate(players.length, (i) {
      Player player = players[i];
      bool hasBeenExcluded = team.contains(player);
      bool isLeader = player.id == leader.id;
      return playerTile(context, player.name, hasBeenExcluded, isLeader);
    });

Widget playerTileText(String playerName, bool hasBeenExcluded, bool isLeader) {
  Color textColor = hasBeenExcluded ? Colors.white : Colors.black87;
  Text text = Text(
    playerName,
    style: TextStyle(color: textColor, fontSize: 16.0),
  );
  if (isLeader) {
    return iconText(Icon(Icons.star, color: textColor), text);
  }
  return text;
}

Widget playerTile(BuildContext context, String playerName, bool hasBeenExcluded, bool isLeader) =>
    Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: HeistColors.peach),
          borderRadius: BorderRadius.circular(5.0),
          color: hasBeenExcluded ? HeistColors.peach : null,
        ),
        child: playerTileText(playerName, hasBeenExcluded, isLeader));
