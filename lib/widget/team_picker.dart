import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget submitTeamButton(BuildContext context, Store<GameModel> store, bool enabled) {
  return new RaisedButton(
    onPressed: enabled ? () => store.dispatch(new SubmitTeamAction()) : null,
    child: new Text(AppLocalizations.of(context).submitTeam, style: buttonTextStyle),
  );
}

Widget teamPicker(Store<GameModel> store) {
  return new StoreConnector<GameModel, Set<Player>>(
      converter: (store) => currentTeam(store.state),
      distinct: true,
      builder: (context, team) {
        Player me = getSelf(store.state);
        int playersRequired = currentHeist(store.state).numPlayers;
        bool goingOnHeist = team.contains(me);
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
                  teamSelectionIcon(goingOnHeist, size: 75.0),
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Text(
                        AppLocalizations.of(context).pickATeam(team.length, playersRequired),
                        style: infoTextStyle,
                      ),
                      new HeistGridView(
                        teamPickerChildren(context, store, team, playersRequired),
                        childAspectRatio: 5.0,
                      ),
                    ],
                  ),
                  new Column(
                    children: [
                      submitTeamButton(context, store, team.length == playersRequired),
                      new Divider(),
                      roundTitleContents(context, store),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

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

List<Widget> teamPickerChildren(
    BuildContext context, Store<GameModel> store, Set<Player> team, int playersRequired) {
  String roundId = currentRound(store.state).id;
  List<Player> players = getPlayers(store.state);
  Player leader = currentLeader(store.state);
  return new List.generate(players.length, (i) {
    Player player = players[i];
    bool isInTeam = team.contains(player);
    bool isLeader = player.id == leader.id;
    bool pickedEnough = !isInTeam && team.length == playersRequired;
    return new InkWell(
        onTap: pickedEnough ? null : () => onTap(store, roundId, player.id, isInTeam),
        child: playerTile(context, player.name, isInTeam, isLeader));
  });
}

void onTap(Store<GameModel> store, String roundId, String playerId, bool isInTeam) {
  if (isInTeam) {
    store.dispatch(new RemovePlayerAction(roundId, playerId));
    store.dispatch(new RemovePlayerMiddlewareAction(playerId));
  } else {
    store.dispatch(new PickPlayerAction(roundId, playerId));
    store.dispatch(new PickPlayerMiddlewareAction(playerId));
  }
}
