import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/haunt_selectors.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class Endgame extends StatefulWidget {
  final Store<GameModel> _store;

  Endgame(this._store);

  @override
  State<StatefulWidget> createState() => _EndgameState();
}

class _EndgameState extends State<Endgame> {
  List<Widget> playerDecisions(Haunt haunt) {
    List<Widget> heistDecisions = [];
    // hauntLeader is null in auctions
    final Player hauntLeader = leaderForHaunt(widget._store.state, haunt);
    bool leaderInHaunt = false;
    haunt.decisions.forEach((playerId, decision) {
      final bool playerIsLeader =
          hauntLeader != null && hauntLeader.id == playerId;
      if (playerIsLeader) {
        leaderInHaunt = true;
      }
      heistDecisions
          .add(getPlayerDecisionRow(playerId, decision, playerIsLeader));
    });
    // make sure the haunt leader appears even if they weren't in the haunt
    if (hauntLeader != null && !leaderInHaunt) {
      heistDecisions.add(getPlayerDecisionRow(hauntLeader.id, "-", true));
    }
    return heistDecisions;
  }

  Row getPlayerDecisionRow(
      final String playerId, final String decision, final bool playerIsLeader) {
    final Player player = getPlayerById(widget._store.state, playerId);
    // put a star next to the leader's name, if there was a leader
    final Widget playerNameText = Text('${player.name}:', style: infoTextStyle);
    final Widget playerName = playerIsLeader
        ? iconText(Icon(Icons.star_border), playerNameText)
        : playerNameText;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        playerName,
        Text(
          ' $decision',
          style: TextStyle(
            fontSize: 16.0,
            color: decisionColour(decision),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Text heistResultText(bool wasSuccess) => wasSuccess
      ? Text(
          AppLocalizations.of(context).success.toUpperCase(),
          style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: HeistColors.green),
        )
      : Text(
          AppLocalizations.of(context).fail.toUpperCase(),
          style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: HeistColors.peach),
        );

  Widget hauntSummary(Haunt haunt, int pot) => Card(
      elevation: 2.0,
      child: Padding(
        padding: paddingMedium,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              iconText(
                  wasAuction(widget._store.state, haunt) ? Icon(Icons.timer) : null,
                  Text(AppLocalizations.of(context).hauntTitle(haunt.order), style: boldTextStyle),
                  trailingIcon: true),
              iconText(
                Icon(Icons.bubble_chart),
                Text(pot.toString(), style: infoTextStyle),
              ),
              heistResultText(haunt.wasSuccess),
            ]),
            Divider(),
            Column(children: playerDecisions(haunt)),
          ],
        ),
      ));

  Widget winner(Score score) => Card(
        elevation: 2.0,
        child: Container(
          alignment: Alignment.center,
          padding: paddingMedium,
          child: Column(
            children: [
              Padding(
                padding: paddingTitle,
                child: Text(
                  AppLocalizations.of(context).winner(score.winner.toString()),
                  style: titleTextStyle,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(Team.SCARY.toString(), style: infoTextStyle),
                  Text(
                    AppLocalizations.of(context)
                        .teamScores(score.scaryScore, score.friendlyScore),
                    style: TextStyle(fontSize: 32.0),
                  ),
                  Text(Team.FRIENDLY.toString(), style: infoTextStyle),
                ],
              )
            ],
          ),
        ),
      );

  Widget fullPlayerListForTeam(List<Player> players, Team team, Color color) {
    List<Player> playersInTeam =
        players.where((p) => Roles.getTeam(p.role) == team).toList();
    return Column(
      children: List.generate(playersInTeam.length, (i) {
        Player player = playersInTeam[i];
        return Padding(
          padding: paddingBelowText,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                player.name,
                style: infoTextStyle,
              ),
              Text(
                Roles.getRoleDisplayName(context, player.role),
                style: TextStyle(color: color),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget fullPlayerList() {
    List<Player> players = getPlayers(widget._store.state);
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: paddingMedium,
        child: Column(children: [
          Padding(
            padding: paddingTitle,
            child: Text(AppLocalizations.of(context).players,
                style: titleTextStyle),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              fullPlayerListForTeam(players, Team.SCARY, HeistColors.peach),
              fullPlayerListForTeam(players, Team.FRIENDLY, Colors.purple),
            ],
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Haunt> haunts = getHaunts(widget._store.state);
    Score score = calculateScore(haunts);

    List<Widget> children = [
      winner(score),
      fullPlayerList(),
    ];

    Map<String, List<Round>> rounds = getRounds(widget._store.state);
    for (Haunt haunt in haunts) {
      if (haunt.allDecided) {
        Round lastRound =
            lastRoundForHaunt(getRoom(widget._store.state), rounds, haunt);
        children.add(hauntSummary(haunt, lastRound.pot));
      }
    }

    return Padding(
      padding: paddingMedium,
      child: ListView(children: children),
    );
  }
}
