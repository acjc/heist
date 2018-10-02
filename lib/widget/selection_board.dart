import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

class SelectionBoard extends StatefulWidget {
  final Store<GameModel> _store;

  SelectionBoard(this._store);

  @override
  State<StatefulWidget> createState() => _SelectionBoardState();
}

class _SelectionBoardState extends State<SelectionBoard> {
  List<Widget> selectionBoardChildren(List<Player> players, Set<Player> team, Player leader) =>
      List.generate(players.length, (i) {
        Player player = players[i];
        bool hasBeenExcluded = team.contains(player);
        bool isLeader = player.id == leader.id;
        return PlayerTile(
          context,
          player.name,
          isLeader,
          hasBeenExcluded,
          HeistColors.peach,
        );
      });

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, Set<Player>>(
      distinct: true,
      converter: (store) => currentExclusions(store.state),
      builder: (context, exclusions) {
        List<Player> players = getPlayers(widget._store.state);
        Player leader = currentLeader(widget._store.state);
        return Card(
          elevation: 2.0,
          child: Padding(
              padding: paddingMedium,
              child: Column(children: [
                Container(
                  padding: paddingTitle,
                  child: Text(
                      '${AppLocalizations.of(context).exclusionsTitle} (${getRoom(widget._store.state).numExclusions})',
                      style: titleTextStyle),
                ),
                TeamGridView(selectionBoardChildren(players, exclusions, leader)),
              ])),
        );
      });
}

class PlayerTile extends StatelessWidget {
  final BuildContext context;
  final String playerName;
  final bool isLeader;
  final bool fill;
  final Color color;

  PlayerTile(this.context, this.playerName, this.isLeader, this.fill, this.color);

  Widget _playerTileText() {
    Color iconColor = fill
        ? Colors.white
        : (Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Colors.white);
    TextStyle textStyle = fill ? TextStyle(color: Colors.white, fontSize: 16.0) : null;
    Text text = Text(playerName, style: textStyle);
    if (isLeader) {
      return iconText(Icon(Icons.star, color: iconColor), text);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: fill ? tileShadow : null,
        color: fill ? color : null,
      ),
      child: _playerTileText());
}
