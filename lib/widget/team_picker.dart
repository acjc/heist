import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'common.dart';

class TeamPicker extends StatefulWidget {
  final Store<GameModel> _store;

  TeamPicker(this._store);

  @override
  State<StatefulWidget> createState() {
    return new TeamPickerState(_store);
  }
}

class TeamPickerState extends State<TeamPicker> with TickerProviderStateMixin {
  final Store<GameModel> _store;

  Animation<Color> _animation;
  AnimationController _controller;

  TeamPickerState(this._store);

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

  Widget _submitTeamButton(BuildContext context, bool enabled) {
    return new RaisedButton(
      onPressed: enabled ? () => _store.dispatch(new SubmitTeamAction()) : null,
      child: new Text(AppLocalizations.of(context).submitTeam, style: buttonTextStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<GameModel, Set<Player>>(
        distinct: true,
        converter: (store) => currentTeam(store.state),
        onInit: (store) => _setUpAnimation(goingOnHeist(store.state)),
        onWillChange: (team) => _setUpAnimation(goingOnHeist(_store.state)),
        onDispose: (gameModel) => _controller?.dispose(),
        builder: (context, team) {
          Player me = getSelf(_store.state);
          int playersRequired = currentHeist(_store.state).numPlayers;
          bool goingOnHeist = team.contains(me);
          _resetAnimation(goingOnHeist);
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
                      builder: (context, value, _) => teamSelectionIcon(goingOnHeist, value, 100.0),
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new Text(
                          AppLocalizations.of(context).pickATeam(team.length, playersRequired),
                          style: infoTextStyle,
                        ),
                        new HeistGridView(
                          _teamPickerChildren(context, team, playersRequired),
                          childAspectRatio: 5.0,
                        ),
                      ],
                    ),
                    new Column(
                      children: [
                        _submitTeamButton(context, team.length == playersRequired),
                        new Divider(),
                        roundTitleContents(context, _store),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  List<Widget> _teamPickerChildren(BuildContext context, Set<Player> team, int playersRequired) {
    String roundId = currentRound(_store.state).id;
    List<Player> players = getPlayers(_store.state);
    Player leader = currentLeader(_store.state);
    return new List.generate(players.length, (i) {
      Player player = players[i];
      bool isInTeam = team.contains(player);
      bool isLeader = player.id == leader.id;
      bool pickedEnough = !isInTeam && team.length == playersRequired;
      return new InkWell(
          onTap: pickedEnough ? null : () => _onTap(_store, roundId, player.id, isInTeam),
          child: playerTile(context, player.name, isInTeam, isLeader));
    });
  }

  void _onTap(Store<GameModel> store, String roundId, String playerId, bool isInTeam) {
    if (isInTeam) {
      store.dispatch(new RemovePlayerAction(roundId, playerId));
      store.dispatch(new RemovePlayerMiddlewareAction(playerId));
    } else {
      store.dispatch(new PickPlayerAction(roundId, playerId));
      store.dispatch(new PickPlayerMiddlewareAction(playerId));
    }
  }
}

Widget playerTileText(String playerName, bool isInTeam, bool isLeader) {
  Color textColor = isInTeam ? Colors.white : Colors.black87;
  Text text = new Text(
    playerName,
    style: new TextStyle(
      color: textColor,
      fontSize: 16.0,
    ),
  );
  if (isLeader) {
    return iconText(new Icon(Icons.star, color: textColor), text);
  }
  return text;
}

Widget playerTile(BuildContext context, String playerName, bool isInTeam, bool isLeader) {
  Color backgroundColor = Theme.of(context).accentColor;
  return new Container(
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        border: new Border.all(color: backgroundColor),
        borderRadius: BorderRadius.circular(5.0),
        color: isInTeam ? backgroundColor : null,
      ),
      child: playerTileText(playerName, isInTeam, isLeader));
}
