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

class ActiveHaunt extends StatefulWidget {
  final Store<GameModel> _store;

  ActiveHaunt(this._store);

  @override
  State<StatefulWidget> createState() => _ActiveHauntState();
}

class _ActiveHauntState extends State<ActiveHaunt> {
  Widget observeHaunt() => StoreConnector<GameModel, Map<String, String>>(
      distinct: true,
      converter: (store) => currentHaunt(store.state).decisions,
      builder: (context, decisions) {
        return Card(
            elevation: 2.0,
            child: Padding(
                padding: paddingMedium,
                child: Column(children: [
                  Text(AppLocalizations.of(context).hauntInProgress, style: infoTextStyle),
                  TeamGridView(
                    observeHauntChildren(currentTeam(widget._store.state), decisions),
                  ),
                ])));
      });

  List<Widget> observeHauntChildren(Set<Player> team, Map<String, String> decisions) {
    Color color = Theme.of(context).primaryColor;
    return List.generate(team.length, (i) {
      Player player = team.elementAt(i);
      bool decisionMade = decisions[player.id] != null;
      return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4.0),
            color: decisionMade ? color : null,
          ),
          child: Text(
            player.name,
            style: TextStyle(fontSize: 16.0, color: decisionMade ? Colors.white : null),
          ));
    });
  }

  Widget makeDecision() => StoreConnector<GameModel, Map<String, String>>(
      distinct: true,
      converter: (store) => currentHaunt(store.state).decisions,
      builder: (context, decisions) {
        Player me = getSelf(widget._store.state);
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
            decisionButton(Scare, true),
            decisionButton(Steal, me.role != Roles.brenda.roleId),
            decisionButton(Tickle, Roles.getTeam(me.role) == Team.FRIENDLY),
          ]);
        }
        return Card(
            elevation: 2.0,
            child: Container(
                padding: paddingMedium,
                alignment: Alignment.center,
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)));
      });

  Widget decisionButton(String decision, bool enabled) => Container(
      padding: paddingSmall,
      child: RaisedButton(
        onPressed: enabled ? () => widget._store.dispatch(MakeDecisionAction(decision)) : null,
        child: Text(decision, style: buttonTextStyle),
      ));

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      roundTitleCard(context, widget._store),
      observeHaunt(),
    ];
    if (goingOnHaunt(widget._store.state)) {
      children.add(makeDecision());
    }
    return Padding(
      padding: paddingMedium,
      child: Column(children: children),
    );
  }
}
