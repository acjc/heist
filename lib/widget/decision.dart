import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/middleware/haunt_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget activeHaunt(BuildContext context, Store<GameModel> store) {
  List<Widget> children = [
    roundTitleCard(context, store),
    observeHaunt(store),
  ];
  if (goingOnHaunt(store.state)) {
    children.add(
      makeDecision(store),
    );
  }
  return Column(children: children);
}

Widget observeHaunt(Store<GameModel> store) => StoreConnector<GameModel, Map<String, String>>(
    converter: (store) => currentHaunt(store.state).decisions,
    distinct: true,
    builder: (context, decisions) {
      return Card(
          elevation: 2.0,
          child: Container(
              padding: paddingMedium,
              child: Column(children: [
                Text(AppLocalizations.of(context).hauntInProgress, style: infoTextStyle),
                TeamGridView(
                  observeHauntChildren(
                    context,
                    currentTeam(store.state),
                    decisions,
                  ),
                ),
              ])));
    });

List<Widget> observeHauntChildren(
    BuildContext context, List<Player> team, Map<String, String> decisions) {
  Color color = Theme.of(context).accentColor;
  return List.generate(team.length, (i) {
    Player player = team[i];
    bool decisionMade = decisions[player.id] != null;
    return Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(border: Border.all(color: color), color: decisionMade ? color : null),
        child: Text(
          player.name,
          style: TextStyle(fontSize: 16.0, color: decisionMade ? Colors.white : null),
        ));
  });
}

Widget makeDecision(Store<GameModel> store) => StoreConnector<GameModel, Map<String, String>>(
    converter: (store) => currentHaunt(store.state).decisions,
    distinct: true,
    builder: (context, decisions) {
      Player me = getSelf(store.state);
      List<Widget> children = [];
      if (decisions.containsKey(me.id)) {
        children.add(
          Text(AppLocalizations.of(context).youHaveMadeYourChoice, style: infoTextStyle),
        );
      } else {
        children.addAll([
          Padding(
            padding: paddingSmall,
            child: Text(AppLocalizations.of(context).makeYourChoice, style: titleTextStyle),
          ),
          decisionButton(store, Scare, true),
          decisionButton(store, Steal, me.role != Roles.brenda.roleId),
          decisionButton(store, Tickle, Roles.getTeam(me.role) == Team.FRIENDLY),
        ]);
      }
      return Card(
          elevation: 2.0,
          child: Container(
              padding: paddingMedium,
              alignment: Alignment.center,
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)));
    });

Widget decisionButton(Store<GameModel> store, String decision, bool enabled) => Padding(
    padding: paddingSmall,
    child: RaisedButton(
      onPressed: enabled ? () => store.dispatch(MakeDecisionAction(decision)) : null,
      child: Text(decision, style: buttonTextStyle),
    ));
