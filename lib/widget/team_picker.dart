import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget submitTeamButton(Store<GameModel> store, Set<String> teamIds, int playersRequired) {
  return new RaisedButton(
    onPressed:
        teamIds.length == playersRequired ? () => store.dispatch(new SubmitTeamAction()) : null,
    child: const Text('SUBMIT TEAM', style: buttonTextStyle),
  );
}

Widget teamPicker(Store<GameModel> store) {
  return new StoreConnector<GameModel, Set<String>>(
      converter: (store) => teamIds(store.state),
      distinct: true,
      builder: (context, teamIds) {
        int playersRequired = currentHeist(store.state).numPlayers;
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                child: new Column(children: [
                  new Text('Pick a team: ${teamIds.length} / $playersRequired',
                      style: infoTextStyle),
                  new GridView.count(
                      padding: paddingMedium,
                      shrinkWrap: true,
                      childAspectRatio: 4.0,
                      crossAxisCount: 2,
                      primary: false,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      children: teamPickerChildren(context, store, teamIds)),
                  submitTeamButton(store, teamIds, playersRequired),
                ])));
      });
}

List<Widget> teamPickerChildren(BuildContext context, Store<GameModel> store, Set<String> teamIds) {
  Color color = Theme.of(context).accentColor;
  String roundId = currentRound(store.state).id;
  List<Player> players = getPlayers(store.state);
  return new List.generate(players.length, (i) {
    Player player = players[i];
    bool isInTeam = teamIds.contains(player.id);
    return new InkWell(
        onTap: () => onTap(store, roundId, player.id, isInTeam),
        child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              border: new Border.all(color: color),
              color: isInTeam ? color : null,
            ),
            child: new Text(
              player.name,
              style: new TextStyle(
                color: isInTeam ? Colors.white : Colors.black87,
                fontSize: 16.0,
              ),
            )));
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
