import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/middleware/haunt_middleware.dart';
import 'package:heist/reducers/local_actions_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/game_history.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class HauntEnd extends StatefulWidget {
  final Store<GameModel> _store;
  final int _hauntOrder;

  HauntEnd(this._store, this._hauntOrder);

  @override
  State<StatefulWidget> createState() => _HauntEndState(_store);
}

class _HauntEndState extends State<HauntEnd> {
  final Store<GameModel> _store;

  _HauntEndState(this._store);

  List<Widget> _hauntDecisions(List<String> decisions) => List.generate(
        decisions.length,
        (i) {
          String decision = decisions[i];
          return Container(
            alignment: Alignment.center,
            padding: paddingTiny,
            child: Text(decision,
                style: TextStyle(
                  fontSize: 16.0,
                  color: decisionColour(decision),
                  fontWeight: FontWeight.bold,
                )),
          );
        },
      );

  Widget _hauntContinueButton(Haunt haunt) => StoreConnector<GameModel, bool>(
      distinct: true,
      converter: (store) => requestInProcess(store.state, Request.CompletingHaunt),
      builder: (context, completingHaunt) => Padding(
            padding: paddingSmall,
            child: RaisedButton(
              child: Text(
                AppLocalizations.of(context).continueButton,
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                if (!haunt.complete && !completingHaunt) {
                  _store.dispatch(CompleteHauntAction());
                }
                _store.dispatch(
                    RecordLocalHauntActionAction(haunt.id, LocalHauntAction.HauntEndContinue));
              },
            ),
          ));

  Widget _hauntIcon(bool wasSuccess) {
    const double size = 40.0;
    return wasSuccess
        ? const Icon(Icons.verified_user, color: HeistColors.green, size: size)
        : const Icon(Icons.cancel, color: HeistColors.peach, size: size);
  }

  Widget _hauntDetails(Haunt haunt, int pot) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(AppLocalizations.of(context).hauntTitle(haunt.order), style: boldTextStyle),
          VerticalDividerHeist(),
          iconText(
            Icon(Icons.bubble_chart),
            Text(pot.toString(), style: bigNumberTextStyle),
          ),
          VerticalDividerHeist(),
          _hauntIcon(haunt.wasSuccess),
        ],
      );

  Widget _hauntResult() {
    Haunt haunt = hauntByOrder(_store.state, widget._hauntOrder);
    List<String> decisions = List.of(haunt.decisions.values.toList());
    if (decisions.isEmpty) {
      return null;
    }
    Round lastRound = lastRoundForHaunt(getRoom(_store.state), getRounds(_store.state), haunt);
    int pot = lastRound.pot;
    decisions.shuffle(Random(haunt.id.hashCode));

    List<Widget> children = [
      _hauntDetails(haunt, pot),
      Divider(),
      hauntTeam(
        context,
        teamForRound(getPlayers(_store.state), lastRound),
        leaderForRound(_store.state, lastRound),
      ),
      Divider(),
    ]..addAll(_hauntDecisions(decisions));

    int brendaPayout = calculateBrendaPayout(newRandomForHaunt(haunt), pot);
    int bertiePayout = pot - brendaPayout;
    TextStyle potResolutionTextStyle = TextStyle(
      fontSize: 30.0,
      color: Theme.of(context).primaryColor,
    );
    children.addAll(
      [
        Divider(),
        Padding(
          padding: paddingSmall,
          child: Column(
            children: [
              Text(
                '+$brendaPayout',
                style: potResolutionTextStyle,
              ),
              Text(AppLocalizations.of(context)
                  .brendaReceived(Roles.getRoleDisplayName(context, Roles.brenda.roleId))),
            ],
          ),
        ),
        Padding(
          padding: paddingSmall,
          child: Column(
            children: [
              Text(
                '+$bertiePayout',
                style: potResolutionTextStyle,
              ),
              Text(AppLocalizations.of(context)
                  .sharedBetween(Roles.getRoleDisplayName(context, Roles.bertie.roleId), Steal)),
            ],
          ),
        ),
        _hauntContinueButton(haunt),
      ],
    );

    return TitledCard(
      margin: paddingMedium,
      title: AppLocalizations.of(context).hauntResult,
      child: Padding(
        padding: paddingMedium,
        child: Column(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!gameIsReady(_store.state)) {
      return Container();
    }
    return SingleChildScrollView(child: _hauntResult());
  }
}
