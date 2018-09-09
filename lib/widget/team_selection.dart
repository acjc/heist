import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/selection_board.dart';
import 'package:redux/redux.dart';

class TeamSelection extends StatefulWidget {
  final Store<GameModel> _store;
  final bool _isMyGo;

  TeamSelection(this._store, this._isMyGo);

  @override
  State<StatefulWidget> createState() {
    return _isMyGo ? new TeamPickerState(_store) : new WaitForTeamState(_store);
  }
}

abstract class TeamSelectionState extends State<TeamSelection> with TickerProviderStateMixin {
  @protected
  final Store<GameModel> _store;

  @protected
  Animation<Color> _pulseAnimation;
  @protected
  AnimationController _pulseController;

  TeamSelectionState(this._store);

  Animation<Color> _getPulseTween(bool goingOnHeist, bool fullTeam) {
    if (fullTeam) {
      Color beginColor = goingOnHeist ? Colors.teal : Colors.red;
      Color endColor = goingOnHeist ? Colors.green : Colors.pinkAccent;
      return new ColorTween(begin: beginColor, end: endColor).animate(_pulseController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _pulseController.forward();
          }
        });
    }
    return new ConstantTween<Color>(goingOnHeist ? Colors.teal : Colors.redAccent)
        .animate(_pulseController);
  }

  @protected
  void _setUpPulse(bool goingOnHeist, bool fullTeam) {
    _pulseController?.dispose();
    _pulseController = null;
    _pulseController = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = _getPulseTween(goingOnHeist, fullTeam);
    _pulseController.forward();
  }

  @protected
  Widget _ghosties(int total) {
    return Container(
      height: 80.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: new List.generate(total, (i) => new Ghostie(i)),
      ),
    );
  }
}

class Ghostie extends StatefulWidget {
  final int _index;

  Ghostie(this._index);

  @override
  State<StatefulWidget> createState() {
    return new GhostieState(_index);
  }
}

class GhostieState extends State<Ghostie> with SingleTickerProviderStateMixin {
  final int _index;

  Animation<Offset> _animation;
  AnimationController _controller;

  GhostieState(this._index);

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = new Tween(begin: const Offset(0.0, 0.6), end: const Offset(0.0, 0.0))
        .animate(new CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => new StoreConnector<GameModel, bool>(
      distinct: true,
      converter: (store) => _index < currentTeam(store.state).length,
      builder: (context, active) {
        if (active) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        return new AnimationListenable<Offset>(
          animation: _animation,
          builder: (context, value, child) => new SlideTransition(
                position: _animation,
                child: child,
              ),
          staticChild: new Transform.rotate(
            angle: pi / 15.0,
            child: const Image(
              image: const AssetImage('assets/graphics/ghostie.png'),
              color: Colors.white,
            ),
          ),
        );
      });
}

class WaitForTeamState extends TeamSelectionState {
  WaitForTeamState(Store<GameModel> store) : super(store);

  @override
  Widget build(BuildContext context) => new StoreConnector<GameModel, bool>(
        distinct: true,
        converter: (store) => goingOnHeist(store.state),
        onInit: (store) => _setUpPulse(goingOnHeist(store.state), currentTeamIsFull(store.state)),
        onWillChange: (goingOnHeist) => _setUpPulse(goingOnHeist, currentTeamIsFull(_store.state)),
        onDispose: (gameModel) => _pulseController?.dispose(),
        builder: (context, goingOnHeist) {
          int playersRequired = currentHeist(_store.state).numPlayers;
          Player leader = currentLeader(_store.state);
          return new AnimationListenable<Color>(
            animation: _pulseAnimation,
            builder: (context, value, child) => new Container(color: value, child: child),
            staticChild: new Column(
              children: [
                _tokenCard(goingOnHeist, leader.name),
                _ghosties(playersRequired),
              ],
            ),
          );
        },
      );

  Widget _waitForTeamMessage(bool goingOnHeist, String leaderName) {
    const TextStyle defaultTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
    if (goingOnHeist) {
      return new RichText(
        textAlign: TextAlign.center,
        text: new TextSpan(
          style: defaultTextStyle,
          children: [
            new TextSpan(text: leaderName, style: boldTextStyle),
            new TextSpan(text: AppLocalizations.of(context).pickedYou),
          ],
        ),
      );
    }

    return new Column(
      children: [
        new Padding(
          padding: paddingSmall,
          child: new Text(AppLocalizations.of(context).notPicked, style: infoTextStyle),
        ),
        new RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            style: defaultTextStyle,
            children: [
              new TextSpan(text: AppLocalizations.of(context).convince),
              new TextSpan(text: leaderName, style: boldTextStyle),
              new TextSpan(text: AppLocalizations.of(context).putYouInTeam),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tokenCard(bool goingOnHeist, String leaderName) => new Expanded(
        child: new Padding(
          padding: paddingMedium,
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: paddingSmall,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new AnimationListenable<Color>(
                    animation: _pulseAnimation,
                    builder: (context, value, _) => teamSelectionIcon(goingOnHeist, value, 250.0),
                  ),
                  _waitForTeamMessage(goingOnHeist, leaderName),
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
        ),
      );
}

class TeamPickerState extends TeamSelectionState {
  TeamPickerState(Store<GameModel> store) : super(store);

  Widget _submitTeamButton(BuildContext context, bool enabled) => new RaisedButton(
        onPressed: enabled ? () => _store.dispatch(new SubmitTeamAction()) : null,
        child: new Text(AppLocalizations.of(context).submitTeam, style: buttonTextStyle),
      );

  @override
  Widget build(BuildContext context) => new StoreConnector<GameModel, Set<Player>>(
      distinct: true,
      converter: (store) => currentTeam(store.state),
      onInit: (store) => _setUpPulse(goingOnHeist(store.state), currentTeamIsFull(store.state)),
      onWillChange: (team) =>
          _setUpPulse(goingOnHeist(_store.state), currentTeamIsFull(_store.state)),
      onDispose: (gameModel) => _pulseController?.dispose(),
      builder: (context, team) {
        int playersRequired = currentHeist(_store.state).numPlayers;
        bool amGoingOnHeist = goingOnHeist(_store.state);
        return new AnimationListenable<Color>(
          animation: _pulseAnimation,
          builder: (context, value, child) => new Container(color: value, child: child),
          staticChild: new Column(
            children: [
              _teamPickerCard(amGoingOnHeist, team, playersRequired),
              _ghosties(playersRequired),
            ],
          ),
        );
      });

  Widget _teamPickerCard(bool goingOnHeist, Set<Player> team, int playersRequired) => new Expanded(
        child: Padding(
          padding: paddingMedium,
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: paddingSmall,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new AnimationListenable<Color>(
                    animation: _pulseAnimation,
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
        ),
      );

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
