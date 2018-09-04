import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';
import 'team_picker.dart';

class WaitForTeam extends StatefulWidget {
  final Store<GameModel> _store;

  WaitForTeam(this._store);

  @override
  State<StatefulWidget> createState() {
    return new WaitForTeamState(_store);
  }
}

class WaitForTeamState extends State<WaitForTeam> with TickerProviderStateMixin {
  final Store<GameModel> _store;

  Animation<Color> _animation;
  AnimationController _controller;

  WaitForTeamState(this._store);

  Widget _waitForTeamMessage(bool goingOnHeist, String leaderName) {
    const TextStyle defaultTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
    if (goingOnHeist) {
      return new RichText(
        textAlign: TextAlign.center,
        text: new TextSpan(
          style: defaultTextStyle,
          children: [
            new TextSpan(text: leaderName, style: boldTextStyle),
            new TextSpan(text: ' picked you in the team!'),
          ],
        ),
      );
    }

    return new Column(
      children: [
        new Padding(
          padding: paddingSmall,
          child: new Text("You haven't been picked!", style: infoTextStyle),
        ),
        new RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            style: defaultTextStyle,
            children: [
              new TextSpan(text: "Convince "),
              new TextSpan(text: leaderName, style: boldTextStyle),
              new TextSpan(text: ' to put you in the team!'),
            ],
          ),
        ),
      ],
    );
  }

  void _setUpAnimation(bool goingOnHeist) {
    _controller?.dispose();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    Color beginColor = goingOnHeist ? Colors.teal : Colors.red;
    Color endColor = goingOnHeist ? Colors.green : Colors.pinkAccent;
    _animation = new ColorTween(begin: beginColor, end: endColor).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  void _resetAnimation(bool goingOnHeist) {
    if (_controller != null) {
      if (!_controller.isAnimating) {
        _controller.forward();
      }
    } else {
      _setUpAnimation(goingOnHeist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<GameModel, bool>(
      distinct: true,
      converter: (store) => goingOnHeist(store.state),
      onInit: (store) => _setUpAnimation(goingOnHeist(store.state)),
      onWillChange: _setUpAnimation,
      onDispose: (gameModel) => _controller?.dispose(),
      builder: (context, goingOnHeist) {
        _resetAnimation(goingOnHeist);
        Player leader = currentLeader(_store.state);
        return new AnimationListenable<Color>(
          animation: _animation,
          builder: (context, value, child) => new Container(
                color: value,
                padding: paddingLarge,
                child: child,
              ),
          staticChild: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: paddingSmall,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new AnimationListenable<Color>(
                    animation: _animation,
                    builder: (context, value, _) => teamSelectionIcon(goingOnHeist, value, 250.0),
                  ),
                  _waitForTeamMessage(goingOnHeist, leader.name),
                  new Column(
                    children: [
                      new Divider(),
                      roundTitleContents(context, _store),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget selectionBoard(Store<GameModel> store) => new StoreConnector<GameModel, Set<Player>>(
    converter: (store) => currentTeam(store.state),
    distinct: true,
    builder: (context, team) {
      List<Player> players = getPlayers(store.state);
      Player leader = currentLeader(store.state);
      return new Card(
        elevation: 2.0,
        child: new Container(
            padding: paddingMedium,
            child: new Column(children: [
              new Container(
                padding: paddingTitle,
                child: new Text(
                    AppLocalizations.of(context).pickedTeamSize(
                      team.length,
                      currentHeist(store.state).numPlayers,
                    ),
                    style: titleTextStyle),
              ),
              new HeistGridView(selectionBoardChildren(context, players, team, leader)),
            ])),
      );
    });

List<Widget> selectionBoardChildren(
    BuildContext context, List<Player> players, Set<Player> team, Player leader) {
  return new List.generate(players.length, (i) {
    Player player = players[i];
    bool isInTeam = team.contains(player);
    bool isLeader = player.id == leader.id;
    return playerTile(context, player.name, isInTeam, isLeader);
  });
}
