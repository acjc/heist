import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/selection_board.dart';
import 'package:redux/redux.dart';

class GameHistory extends StatefulWidget {
  final Store<GameModel> _store;

  GameHistory(this._store);

  @override
  State<StatefulWidget> createState() => _GameHistoryState();
}

class _GameHistoryState extends State<GameHistory> {
  Widget hauntDecisions(Haunt haunt) {
    List<String> decisions = List.of(haunt.decisions.values.toList());
    decisions.shuffle(Random(haunt.id.hashCode));
    List<Widget> children = List.generate(decisions.length, (i) {
      String decision = decisions[i];
      return Center(
        child: Text(decision,
            style: TextStyle(
              fontSize: 16.0,
              color: decisionColour(decision),
              fontWeight: FontWeight.bold,
            )),
      );
    });
    return TeamGridView(children, childAspectRatio: 8.0);
  }

  Widget hauntDetailsIcon(IconData icon, String text) => iconText(
        Icon(icon, color: Colors.grey),
        Text(text, style: Theme.of(context).textTheme.caption),
      );

  String getHeistStatus(BuildContext context, Haunt haunt, Round lastRound) {
    if (haunt.complete) {
      return haunt.wasSuccess
          ? AppLocalizations.of(context).success
          : AppLocalizations.of(context).fail;
    }
    if (lastRound.isAuction) {
      return AppLocalizations.of(context).auctionTitle;
    }
    return AppLocalizations.of(context).roundTitle(lastRound.order);
  }

  Icon getHauntIcon(Haunt haunt, int currentHauntOrder) {
    const double size = 32.0;
    if (haunt.order > currentHauntOrder) {
      return const Icon(Icons.remove, size: size, color: Colors.blueGrey);
    }
    if (!haunt.complete) {
      return const Icon(Icons.adjust, color: HeistColors.amber);
    }
    if (haunt.wasSuccess) {
      return const Icon(Icons.verified_user, color: HeistColors.green, size: size);
    }
    return const Icon(Icons.cancel, color: HeistColors.peach, size: size);
  }

  Widget hauntPopup(int currentHauntOrder, Haunt haunt) {
    Round lastRound = lastRoundForHaunt(
      getRoom(widget._store.state),
      getRounds(widget._store.state),
      haunt,
    );

    List<Widget> title = [
      Text(
        AppLocalizations.of(context).hauntTitle(haunt.order),
        style: Theme.of(context).textTheme.subhead,
      ),
    ];

    title.add(Text(
      getHeistStatus(context, haunt, lastRound),
      style: Theme.of(context).textTheme.caption,
    ));

    List<Widget> hauntDetailsChildren = [
      getHauntIcon(haunt, currentHauntOrder),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: title,
      ),
      VerticalDivider(height: 40.0),
      hauntDetailsIcon(Icons.people, haunt.numPlayers.toString()),
      hauntDetailsIcon(Icons.bubble_chart, haunt.price.toString()),
      hauntDetailsIcon(Icons.vertical_align_top, haunt.maximumBid.toString()),
    ];

    if (haunt.complete) {
      hauntDetailsChildren.addAll([
        VerticalDivider(height: 40.0),
        iconText(Icon(Icons.bubble_chart, size: 32.0),
            Text(lastRound.pot.toString(), style: bigNumberTextStyle)),
      ]);
    }

    List<Widget> hauntPopupChildren = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: hauntDetailsChildren,
      ),
    ];

    if (haunt.complete) {
      Set<Player> team = teamForRound(getPlayers(widget._store.state), lastRound);
      Player leader = leaderForRound(widget._store.state, lastRound);
      hauntPopupChildren.addAll([
        Divider(),
        hauntTeam(context, team, leader),
        Divider(),
        hauntDecisions(haunt),
      ]);
    }

    return Padding(
      padding: paddingMedium,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: hauntPopupChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, List<Haunt>>(
      distinct: true,
      converter: (store) => getHaunts(store.state),
      builder: (context, haunts) {
        if (haunts.isEmpty) {
          return Container();
        }
        int currentHauntOrder = currentHaunt(widget._store.state).order;
        return Card(
          elevation: 10.0,
          color: Colors.white24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              Haunt haunt = haunts[i];
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: (context) => hauntPopup(currentHauntOrder, haunt));
                  return;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  child: getHauntIcon(haunt, currentHauntOrder),
                ),
              );
            }),
          ),
        );
      });
}

Widget hauntTeam(BuildContext context, Set<Player> team, Player leader) {
  List<Widget> gridChildren = List.generate(
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

  return TeamGridView(gridChildren);
}
