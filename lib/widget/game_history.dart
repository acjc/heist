import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/heist_definitions.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';
import 'selection_board.dart';

Widget heistDecisions(Heist heist) {
  List<String> decisions = new List.of(heist.decisions.values.toList());
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
  return new Column(
    children: children,
  );
}

Widget heistPopup(BuildContext context, Store<GameModel> store, Heist heist, int order) {
  int totalPlayers = getRoom(store.state).numPlayers;
  int price = heist?.price ?? heistDefinitions[totalPlayers][order].price;
  int numPlayers = heist?.numPlayers ?? heistDefinitions[totalPlayers][order].numPlayers;
  int maximumBid = heist?.maximumBid ?? heistDefinitions[totalPlayers][order].maximumBid;
  Round lastRound = heist != null ? getRounds(store.state)[heist.id].last : null;
  int pot = lastRound != null && lastRound.bids.length == numPlayers ? lastRound.pot : null;

  List<Widget> title = [
    new Text(
      'Heist $order',
      style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    ),
  ];

  if (heist != null) {
    title.add(new Text(
      getHeistStatus(heist, lastRound),
      style: subtitleTextStyle,
    ));
  }

  List<Widget> children = [
    new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: title,
      ),
      getHeistIcon(heist),
    ]),
    new Divider(),
    new Container(
      padding: paddingSmall,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text('Players: $numPlayers', style: subtitleTextStyle),
          new Text('Price: $price', style: subtitleTextStyle),
          new Text('Maximum bid: $maximumBid', style: subtitleTextStyle),
        ],
      ),
    ),
  ];

  if (pot != null) {
    children.add(
      new Container(
        padding: paddingSmall,
        child: new Chip(
          label: new Text(
            'Pot: $pot',
            style: chipTextStyle,
          ),
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }

  if (heist != null && heist.complete) {
    List<Player> players = getPlayers(store.state);
    Set<String> teamNames =
        players.where((p) => lastRound.team.contains(p.id)).map((p) => p.name).toSet();
    children.addAll([
      new Divider(),
      selectionGrid(context, players, teamNames),
      heistDecisions(heist),
    ]);
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

String getHeistStatus(Heist heist, Round lastRound) {
  if (heist.complete) {
    return heist.wasSuccess ? 'Success' : 'Fail';
  }
  if (lastRound == null) {
    return 'Round 1';
  }
  if (lastRound.isAuction) {
    return 'Auction!';
  }
  return 'Round ${lastRound.order}';
}

Icon getHeistIcon(Heist heist) {
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
                        context: context,
                        builder: (context) => heistPopup(context, store, heist, i + 1));
                  },
                  child: new Container(
                    padding: paddingMedium,
                    child: getHeistIcon(heist),
                  ),
                );
              }),
            ));
      });
}
