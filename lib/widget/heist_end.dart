import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/heist_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget heistContinueButton(Store<GameModel> store) {
  return new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingHeist),
      distinct: true,
      builder: (context, completingHeist) => new Padding(
            padding: paddingSmall,
            child: new RaisedButton(
              child: Text(AppLocalizations.of(context).continueButton, style: buttonTextStyle),
              onPressed: completingHeist ? null : () => store.dispatch(new CompleteHeistAction()),
            ),
          ));
}

Widget heistEnd(Store<GameModel> store) {
  Heist heist = currentHeist(store.state);
  List<String> decisions = new List.of(heist.decisions.values.toList());
  if (decisions.isEmpty) {
    return null;
  }
  decisions.shuffle(new Random(heist.id.hashCode));
  List<Widget> children = new List.generate(decisions.length, (i) {
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
  });

  if (amOwner(store.state)) {
    children.add(heistContinueButton(store));
  }

  return new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    ),
  );
}
