import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/middleware/heist_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget observeHeist(Store<GameModel> store) {
  return new StoreConnector<GameModel, Map<String, String>>(
      converter: (store) => currentHeist(store.state).decisions,
      distinct: true,
      builder: (context, decisions) {
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                child: new Column(children: [
                  Text(AppLocalizations.of(context).heistInProgress, style: infoTextStyle),
                  new GridView.count(
                    padding: paddingMedium,
                    shrinkWrap: true,
                    childAspectRatio: 6.0,
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: observeHeistChildren(context, playersInTeam(store.state), decisions),
                  )
                ])));
      });
}

List<Widget> observeHeistChildren(
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
        converter: (store) => currentHeist(store.state).decisions,
        distinct: true,
        builder: (context, decisions) {
          Player me = getSelf(store.state);
          if (decisions.containsKey(me.id)) {
            return observeHeist(store);
          } else {
            List<Widget> children = [
              roundTitle(context, store),
              new Padding(
                padding: paddingSmall,
                child: Text(AppLocalizations.of(context).makeYourChoice, style: titleTextStyle),
              ),
              new Text(AppLocalizations.of(context).youAreOnAHeist, style: infoTextStyle),
              new Column(
                children: [],
              ),
              decisionButton(context, store, Succeed, true),
              decisionButton(context, store, Steal, me.role != KINGPIN.roleId),
              decisionButton(context, store, Fail, getTeam(me.role) == Team.AGENTS),
            ];
            return new Card(
                elevation: 2.0,
                child: new Container(
                    padding: paddingMedium,
                    alignment: Alignment.center,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)));
          }
        });

Widget decisionButton(
        BuildContext context, Store<GameModel> store, String decision, bool enabled) =>
    new Container(
        padding: paddingSmall,
        child: new RaisedButton(
          onPressed: enabled ? () => store.dispatch(new MakeDecisionAction(decision)) : null,
          child: new Text(decision, style: buttonTextStyle),
        ));
