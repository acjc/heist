import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/middleware/heist_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/game_history.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class HeistEnd extends StatefulWidget {
  final Store<GameModel> _store;

  HeistEnd(this._store);

  @override
  State<StatefulWidget> createState() {
    return new HeistEndState(_store);
  }
}

class HeistEndState extends State<HeistEnd> {
  final Store<GameModel> _store;

  HeistEndState(this._store);

  List<Widget> _heistDecisions(List<String> decisions) => new List.generate(
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

  Widget _heistContinueButton() {
    return new StoreConnector<GameModel, bool>(
        converter: (store) => requestInProcess(store.state, Request.CompletingHeist),
        distinct: true,
        builder: (context, completingHeist) => new Padding(
              padding: paddingSmall,
              child: new RaisedButton(
                child: new Text(
                  AppLocalizations.of(context).continueButton,
                  style: buttonTextStyle,
                ),
                onPressed:
                    completingHeist ? null : () => _store.dispatch(new CompleteHeistAction()),
              ),
            ));
  }

  Widget _heistIcon(bool wasSuccess) {
    return wasSuccess
        ? const Icon(Icons.verified_user, color: Colors.green, size: 40.0)
        : const Icon(Icons.cancel, color: Colors.red, size: 40.0);
  }

  Widget _heistDetails(Heist heist, int pot) => new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(AppLocalizations.of(context).heistTitle(heist.order), style: boldTextStyle),
          new VerticalDivider(),
          iconText(
            new Icon(Icons.monetization_on, color: Colors.teal),
            new Text(pot.toString(), style: bigNumberTextStyle),
          ),
          new VerticalDivider(),
          _heistIcon(heist.wasSuccess),
        ],
      );

  Widget _heistResult(BuildContext context) {
    Heist heist = currentHeist(_store.state);
    List<String> decisions = new List.of(heist.decisions.values.toList());
    if (decisions.isEmpty) {
      return null;
    }
    int pot = currentRound(_store.state).pot;
    decisions.shuffle(new Random(heist.id.hashCode));

    List<Widget> children = [
      _heistDetails(heist, pot),
      new Divider(),
      heistTeam(context, _store, currentTeam(_store.state), currentLeader(_store.state)),
      new Divider(),
    ];

    children.addAll(_heistDecisions(decisions));

    int kingpinPayout = calculateKingpinPayout(newRandomForHeist(heist), pot);
    int leadAgentPayout = pot - kingpinPayout;
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
              '+$kingpinPayout',
              style: potResolutionTextStyle,
            ),
            new Text(
              AppLocalizations.of(context).kingpinReceived(
                  getRoleDisplayName(context, KINGPIN.roleId)),
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
              '+$leadAgentPayout',
              style: potResolutionTextStyle,
            ),
            new Text(
              AppLocalizations.of(context).sharedBetween(
                  getRoleDisplayName(context, LEAD_AGENT.roleId), Steal),
              style: infoTextStyle,
            ),
          ],
        ),
      ),
    ]);

    if (amOwner(_store.state)) {
      children.add(_heistContinueButton());
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
    return new SingleChildScrollView(child: _heistResult(context));
  }
}
