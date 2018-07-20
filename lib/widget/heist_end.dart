import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/middleware/heist_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget heistContinueButton(Store<GameModel> store) {
  return new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingHeist),
      distinct: true,
      builder: (context, completingHeist) => new RaisedButton(
            child: const Text('CONTINUE', style: buttonTextStyle),
            onPressed: completingHeist ? null : () => store.dispatch(new CompleteHeistAction()),
          ));
}

Widget heistEnd(Store<GameModel> store) {
  List<String> decisions = currentHeist(store.state).decisions.values.toList();
  if (decisions.isEmpty) {
    return null;
  }
  List<Widget> children = new List.generate(decisions.length, (i) {
    String decision = decisions[i];
    return new Container(
      alignment: Alignment.center,
      padding: paddingSmall,
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
