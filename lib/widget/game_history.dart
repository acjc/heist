import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

Widget heistDecisions(Heist heist) {
  List<String> decisions = heist.decisions.values.toList();
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
  return new Column(
    children: children,
  );
}

// TODO: for current heist, show which round it is
Widget heistPopup(Store<GameModel> store, Heist heist, int order) {
  int totalPlayers = getRoom(store.state).numPlayers;
  int price = heist?.price ?? heistDefinitions[totalPlayers][order].price;
  int numPlayers = heist?.numPlayers ?? heistDefinitions[totalPlayers][order].numPlayers;
  int maximumBid = heist?.maximumBid ?? heistDefinitions[totalPlayers][order].maximumBid;
  Round lastRound = heist != null ? getRounds(store.state)[heist.id].last : null;
  int pot = lastRound != null && lastRound.bids.length == numPlayers ? lastRound.pot : null;

  List<Widget> heistDetails = [
    new Chip(
      label: new Text(
        'Price: $price',
        style: chipTextStyle,
      ),
      backgroundColor: Colors.orange,
    ),
    new Chip(
      label: new Text(
        'Maximum bid: $maximumBid',
        style: chipTextStyle,
      ),
      backgroundColor: Colors.orange,
    ),
  ];
  if (pot != null) {
    heistDetails.add(
      new Chip(
        label: new Text(
          'Pot: $pot',
          style: chipTextStyle,
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  List<Widget> children = [
    new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      new Text('Heist ${order + 1} ($numPlayers players)',
          style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      getIcon(heist),
    ]),
    new Divider(),
    new Container(
      padding: paddingSmall,
      child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: heistDetails),
    ),
  ];

  if (heist != null && heist.complete) {
    children.add(heistDecisions(heist));
  }

  return new Container(
    padding: paddingLarge,
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: children,
    ),
  );
}

Icon getIcon(Heist heist) {
  if (heist == null) {
    return const Icon(Icons.remove, size: 32.0);
  }
  if (!heist.complete) {
    return const Icon(Icons.adjust, color: Colors.blue);
  }
  if (heist.wasSuccess) {
    return const Icon(Icons.verified_user, color: Colors.green, size: 32.0);
  }
  return const Icon(Icons.cancel, color: Colors.red, size: 32.0);
}

Widget gameHistory(Store<GameModel> store) {
  return new StoreConnector<GameModel, List<Heist>>(
      distinct: true,
      converter: (store) => store.state.heists,
      builder: (context, heists) {
        if (heists.isEmpty) {
          return new Container();
        }
        return new Card(
            elevation: 10.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: new List.generate(5, (i) {
                Heist heist = i < heists.length ? heists[i] : null;
                return new InkWell(
                  onTap: () {
                    return showModalBottomSheet(
                        context: context, builder: (context) => heistPopup(store, heist, i + 1));
                  },
                  child: new Container(
                    padding: paddingMedium,
                    child: getIcon(heist),
                  ),
                );
              }),
            ));
      });
}
