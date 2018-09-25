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
      makeDecision(context, store),
    );
  }
  return new Column(children: children);
}

Widget observeHaunt(Store<GameModel> store) {
  return new StoreConnector<GameModel, Map<String, String>>(
      converter: (store) => currentHaunt(store.state).decisions,
      distinct: true,
      builder: (context, decisions) {
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                child: new Column(children: [
                  new Text(AppLocalizations.of(context).hauntInProgress, style: infoTextStyle),
                  new TeamGridView(
                    observeHauntChildren(
                      context,
                      currentTeam(store.state),
                      decisions,
                    ),
                  ),
                ])));
      });
}

List<Widget> observeHauntChildren(
    BuildContext context, Set<Player> team, Map<String, String> decisions) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(team.length, (i) {
    Player player = team.elementAt(i);
    bool decisionMade = decisions[player.id] != null;
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            border: new Border.all(color: color), color: decisionMade ? color : null),
        child: new Text(
          player.name,
          style: new TextStyle(fontSize: 16.0, color: decisionMade ? Colors.white : null),
        ));
  });
}

Widget makeDecision(BuildContext context, Store<GameModel> store) =>
    new StoreConnector<GameModel, Map<String, String>>(
        converter: (store) => currentHaunt(store.state).decisions,
        distinct: true,
        builder: (context, decisions) {
          Player me = getSelf(store.state);
          List<Widget> children = [];
          if (decisions.containsKey(me.id)) {
            children.add(
              new Text(AppLocalizations.of(context).youHaveMadeYourChoice, style: infoTextStyle),
            );
          } else {
            children.addAll([
              new Padding(
                padding: paddingSmall,
                child: new Text(AppLocalizations.of(context).makeYourChoice, style: titleTextStyle),
              ),
              new Column(
                children: [],
              ),
              decisionButton(context, store, Scare, true),
              decisionButton(context, store, Steal, me.role != Roles.brenda.roleId),
              decisionButton(context, store, Tickle, Roles.getTeam(me.role) == Team.FRIENDLY),
            ]);
          }
          return new Card(
              elevation: 2.0,
              child: new Container(
                  padding: paddingMedium,
                  alignment: Alignment.center,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)));
        });

Widget decisionButton(
        BuildContext context, Store<GameModel> store, String decision, bool enabled) =>
    new Container(
        padding: paddingSmall,
        child: new RaisedButton(
          onPressed: enabled ? () => store.dispatch(new MakeDecisionAction(decision)) : null,
          child: new Text(decision, style: buttonTextStyle),
        ));
