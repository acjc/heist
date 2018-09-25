import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/middleware/haunt_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/game_history.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class HauntEnd extends StatefulWidget {
  final Store<GameModel> _store;

  HauntEnd(this._store);

  @override
  State<StatefulWidget> createState() {
    return new _HauntEndState(_store);
  }
}

class _HauntEndState extends State<HauntEnd> {
  final Store<GameModel> _store;

  _HauntEndState(this._store);

  List<Widget> _hauntDecisions(List<String> decisions) => new List.generate(
        decisions.length,
        (i) {
          String decision = decisions[i];
          return new Container(
            alignment: Alignment.center,
            padding: paddingTiny,
            child: new Text(decision,
                style: new TextStyle(
                  fontSize: 16.0,
                  color: decisionColour(decision),
                  fontWeight: FontWeight.bold,
                )),
          );
        },
      );

  Widget _hauntContinueButton() {
    return new StoreConnector<GameModel, bool>(
        converter: (store) => requestInProcess(store.state, Request.CompletingHaunt),
        distinct: true,
        builder: (context, completingHeist) => new Padding(
              padding: paddingSmall,
              child: new RaisedButton(
                child: new Text(
                  AppLocalizations.of(context).continueButton,
                  style: buttonTextStyle,
                ),
                onPressed:
                    completingHeist ? null : () => _store.dispatch(new CompleteHauntAction()),
              ),
            ));
  }

  Widget _hauntIcon(bool wasSuccess) {
    return wasSuccess
        ? const Icon(Icons.verified_user, color: HeistColors.green, size: 40.0)
        : const Icon(Icons.cancel, color: Colors.red, size: 40.0);
  }

  Widget _hauntDetails(Haunt haunt, int pot) => new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(AppLocalizations.of(context).hauntTitle(haunt.order), style: boldTextStyle),
          new VerticalDivider(),
          iconText(
            new Icon(Icons.monetization_on, color: Colors.teal),
            new Text(pot.toString(), style: bigNumberTextStyle),
          ),
          new VerticalDivider(),
          _hauntIcon(haunt.wasSuccess),
        ],
      );

  Widget _hauntResult(BuildContext context) {
    Haunt haunt = currentHaunt(_store.state);
    List<String> decisions = new List.of(haunt.decisions.values.toList());
    if (decisions.isEmpty) {
      return null;
    }
    int pot = currentRound(_store.state).pot;
    decisions.shuffle(new Random(haunt.id.hashCode));

    List<Widget> children = [
      _hauntDetails(haunt, pot),
      new Divider(),
      hauntTeam(context, currentTeam(_store.state), currentLeader(_store.state)),
      new Divider(),
    ];

    children.addAll(_hauntDecisions(decisions));

    int brendaPayout = calculateBrendaPayout(newRandomForHaunt(haunt), pot);
    int bertiePayout = pot - brendaPayout;
    TextStyle potResolutionTextStyle = const TextStyle(
      fontSize: 30.0,
      fontWeight: FontWeight.w300,
      color: Colors.teal,
    );
    children.addAll([
      new Divider(),
      new Padding(
        padding: paddingSmall,
        child: new Column(
          children: [
            new Text(
              '+$brendaPayout',
              style: potResolutionTextStyle,
            ),
            new Text(
              AppLocalizations.of(context)
                  .brendaReceived(Roles.getRoleDisplayName(context, Roles.brenda.roleId)),
              style: infoTextStyle,
            ),
          ],
        ),
      ),
      new Padding(
        padding: paddingSmall,
        child: new Column(
          children: [
            new Text(
              '+$bertiePayout',
              style: potResolutionTextStyle,
            ),
            new Text(
              AppLocalizations.of(context)
                  .sharedBetween(Roles.getRoleDisplayName(context, Roles.bertie.roleId), Steal),
              style: infoTextStyle,
            ),
          ],
        ),
      ),
    ]);

    if (amOwner(_store.state)) {
      children.add(_hauntContinueButton());
    }

    return new Card(
      elevation: 2.0,
      child: new Container(
        padding: paddingMedium,
        child: new Column(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!gameIsReady(_store.state)) {
      return new Container();
    }
    return new SingleChildScrollView(child: _hauntResult(context));
  }
}
