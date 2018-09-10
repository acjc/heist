import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/selection_board.dart';
import 'package:redux/redux.dart';

Widget heistDecisions(Haunt heist) {
  List<String> decisions = new List.of(heist.decisions.values.toList());
  decisions.shuffle(new Random(heist.id.hashCode));
  List<Widget> children = new List.generate(decisions.length, (i) {
    String decision = decisions[i];
    return new Center(
      child: new Text(decision,
          style: new TextStyle(
            fontSize: 16.0,
            color: decisionColour(decision),
            fontWeight: FontWeight.bold,
          )),
    );
  });
  return new TeamGridView(children, childAspectRatio: 8.0);
}

Widget heistTeam(BuildContext context, Store<GameModel> store, Set<Player> team, Player leader) {
  List<Widget> gridChildren = new List.generate(
    team.length,
    (i) {
      Player player = team.elementAt(i);
      bool isLeader = player.id == leader.id;
      return playerTile(context, player.name, true, isLeader);
    },
  );

  if (!team.contains(leader)) {
    gridChildren.add(playerTile(context, leader.name, false, true));
  }

  return new TeamGridView(gridChildren);
}

Widget heistPopup(BuildContext context, Store<GameModel> store, Haunt heist, int order) {
  int totalPlayers = getRoom(store.state).numPlayers;
  int price = heist?.price ?? hauntDefinitions[totalPlayers][order].price;
  int numPlayers = heist?.numPlayers ?? hauntDefinitions[totalPlayers][order].numPlayers;
  int maximumBid = heist?.maximumBid ?? hauntDefinitions[totalPlayers][order].maximumBid;
  Round lastRound = heist != null ? getRounds(store.state)[heist.id].last : null;
  int pot = lastRound != null && lastRound.bids.length == numPlayers ? lastRound.pot : null;

  List<Widget> title = [
    new Text(
      AppLocalizations.of(context).hauntTitle(order),
      style: boldTextStyle,
    ),
  ];

  if (heist != null) {
    title.add(new Text(
      getHeistStatus(context, heist, lastRound),
      style: subtitleTextStyle,
    ));
  }

  List<Widget> heistDetailsChildren = [
    getHeistIcon(heist),
    new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: title,
    ),
    new VerticalDivider(height: 40.0),
    heistDetailsIcon(Icons.people, numPlayers.toString()),
    heistDetailsIcon(Icons.bubble_chart, price.toString()),
    heistDetailsIcon(Icons.vertical_align_top, maximumBid.toString()),
  ];

  if (pot != null) {
    heistDetailsChildren.addAll([
      new VerticalDivider(height: 40.0),
      iconText(new Icon(Icons.bubble_chart, size: 32.0),
          new Text(pot.toString(), style: bigNumberTextStyle)),
    ]);
  }

  List<Widget> heistPopupChildren = [
    new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: heistDetailsChildren,
    ),
  ];

  if (heist != null && heist.complete) {
    Set<Player> team = teamForRound(store.state, lastRound);
    Player leader = leaderForRound(store.state, lastRound);
    heistPopupChildren.addAll([
      new Divider(),
      heistTeam(context, store, team, leader),
      new Divider(),
      heistDecisions(heist),
    ]);
  }

  return new Container(
    padding: paddingMedium,
    child: new Column(
      mainAxisSize: MainAxisSize.min,
      children: heistPopupChildren,
    ),
  );
}

Widget heistDetailsIcon(IconData icon, String text) {
  return iconText(
    new Icon(icon, color: Colors.grey),
    new Text(text, style: subtitleTextStyle),
  );
}

String getHeistStatus(BuildContext context, Haunt heist, Round lastRound) {
  if (heist.complete) {
    return heist.wasSuccess
        ? AppLocalizations.of(context).success
        : AppLocalizations.of(context).fail;
  }
  if (lastRound == null) {
    return AppLocalizations.of(context).roundTitle(1);
  }
  if (lastRound.isAuction) {
    return AppLocalizations.of(context).auctionTitle;
  }
  return AppLocalizations.of(context).roundTitle(lastRound.order);
}

Icon getHeistIcon(Haunt heist) {
  if (heist == null) {
    return const Icon(Icons.remove, size: 32.0, color: Colors.grey);
  }
  if (!heist.complete) {
    return const Icon(Icons.adjust, color: HeistColors.blue);
  }
  if (heist.wasSuccess) {
    return const Icon(Icons.verified_user, color: HeistColors.green, size: 32.0);
  }
  return const Icon(Icons.cancel, color: Colors.red, size: 32.0);
}

Widget gameHistory(Store<GameModel> store) {
  return new StoreConnector<GameModel, List<Haunt>>(
      distinct: true,
      converter: (store) => store.state.haunts,
      builder: (context, heists) {
        if (heists.isEmpty) {
          return new Container();
        }
        return new Card(
            elevation: 10.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: new List.generate(5, (i) {
                Haunt heist = i < heists.length ? heists[i] : null;
                return new InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => heistPopup(context, store, heist, i + 1));
                    return;
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
