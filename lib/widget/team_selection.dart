import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/reducers/local_actions_reducers.dart';
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
    return _isMyGo ? TeamPickerState(_store) : _WaitForTeamState(_store);
  }
}

abstract class TeamSelectionState extends State<TeamSelection> with TickerProviderStateMixin {
  @protected
  final Store<GameModel> _store;

  @protected
  Animation<Color> _pulseAnimation;
  @protected
  AnimationController _pulseController;

  @protected
  Animation<double> _continueAnimation;
  @protected
  AnimationController _continueController;

  TeamSelectionState(this._store);

  @override
  initState() {
    super.initState();
    _continueController =
        AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _continueAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _continueController, curve: Curves.ease));
  }

  @override
  dispose() {
    _continueController?.dispose();
    _continueController = null;
    _pulseController?.dispose();
    _pulseController = null;
    super.dispose();
  }

  Animation<Color> _getPulseTween(bool goingOnHaunt, bool fullTeam) {
    if (fullTeam) {
      Color beginColor = goingOnHaunt ? Colors.green : Colors.redAccent;
      Color endColor = goingOnHaunt ? HeistColors.green : HeistColors.peach;
      return ColorTween(begin: beginColor, end: endColor).animate(_pulseController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _pulseController.forward();
          }
        });
    }
    return ConstantTween<Color>(goingOnHaunt ? HeistColors.green : HeistColors.peach)
        .animate(_pulseController);
  }

  @protected
  void _setUpPulse(bool goingOnHaunt, bool fullTeam) {
    _pulseController?.dispose();
    _pulseController = null;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = _getPulseTween(goingOnHaunt, fullTeam);
    _pulseController.forward();
  }

  @protected
  void _runContinueButtonAnimation(bool teamSubmitted) {
    if (teamSubmitted && _continueController.isDismissed) {
      _continueController.forward();
    }
  }

  @protected
  Widget _continueButton() => FadeTransition(
        opacity: _continueAnimation,
        child: RaisedButton(
            child: Text(
              AppLocalizations.of(context).continueToBidding,
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () => _store.dispatch(RecordLocalRoundActionAction(
                  currentRound(_store.state).id,
                  LocalRoundAction.TeamSelectionContinue,
                ))),
      );

  @protected
  Widget _ghosties(int total) => Container(
        height: 80.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(total, (i) => Ghostie(i)),
        ),
      );
}

class Ghostie extends StatefulWidget {
  final int _index;

  Ghostie(this._index);

  @override
  State<StatefulWidget> createState() {
    return GhostieState(_index);
  }
}

class GhostieState extends State<Ghostie> with SingleTickerProviderStateMixin {
  final int _index;

  Animation<Offset> _animation;
  AnimationController _controller;

  GhostieState(this._index);

  void _setUpAnimation() {
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(begin: const Offset(0.0, 0.6), end: const Offset(0.0, 0.0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  void _runAnimation(bool active) {
    if (active) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, bool>(
      distinct: true,
      onInit: (store) => _setUpAnimation(),
      onInitialBuild: _runAnimation,
      onWillChange: _runAnimation,
      onDispose: (_) {
        _controller?.dispose();
        _controller = null;
      },
      converter: (store) => _index < currentTeam(store.state).length,
      builder: (context, active) => SlideTransition(
            position: _animation,
            child: Transform.rotate(
              angle: pi / 15.0,
              child: const Image(
                image: const AssetImage('assets/graphics/ghostie.png'),
                color: Colors.white,
              ),
            ),
          ));
}

class _WaitForTeamViewModel {
  @required
  bool goingOnHaunt;
  @required
  bool currentTeamIsFull;
  @required
  bool teamSubmitted;

  _WaitForTeamViewModel({this.goingOnHaunt, this.currentTeamIsFull, this.teamSubmitted});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WaitForTeamViewModel &&
          runtimeType == other.runtimeType &&
          goingOnHaunt == other.goingOnHaunt &&
          currentTeamIsFull == other.currentTeamIsFull &&
          teamSubmitted == other.teamSubmitted;

  @override
  int get hashCode => goingOnHaunt.hashCode ^ currentTeamIsFull.hashCode ^ teamSubmitted.hashCode;

  @override
  String toString() {
    return '_WaitForTeamViewModel{goingOnHaunt: $goingOnHaunt, currentTeamIsFull: $currentTeamIsFull, teamSubmitted: $teamSubmitted}';
  }
}

class _WaitForTeamState extends TeamSelectionState {
  _WaitForTeamState(Store<GameModel> store) : super(store);

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, _WaitForTeamViewModel>(
        distinct: true,
        converter: (store) => _WaitForTeamViewModel(
              goingOnHaunt: goingOnHaunt(store.state),
              currentTeamIsFull: currentTeamIsFull(store.state),
              teamSubmitted: currentRound(store.state).teamSubmitted,
            ),
        onInit: (store) => _setUpPulse(goingOnHaunt(store.state), currentTeamIsFull(store.state)),
        onInitialBuild: (viewModel) => _runContinueButtonAnimation(viewModel.teamSubmitted),
        onWillChange: (viewModel) =>
            _setUpPulse(viewModel.goingOnHaunt, viewModel.currentTeamIsFull),
        onDidChange: (viewModel) => _runContinueButtonAnimation(viewModel.teamSubmitted),
        builder: (context, viewModel) {
          int playersRequired = currentHaunt(_store.state).numPlayers;
          Player leader = currentLeader(_store.state);
          return AnimationListenable<Color>(
            animation: _pulseAnimation,
            builder: (context, value, child) => Container(color: value, child: child),
            staticChild: Column(
              children: [
                _tokenCard(viewModel.goingOnHaunt, leader.name, viewModel.teamSubmitted),
                _ghosties(playersRequired),
              ],
            ),
          );
        },
      );

  Widget _waitForTeamMessage(bool goingOnHaunt, String leaderName) {
    const TextStyle defaultTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
    if (goingOnHaunt) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: defaultTextStyle,
          children: [
            TextSpan(text: leaderName, style: boldTextStyle),
            TextSpan(text: AppLocalizations.of(context).pickedYou),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: paddingSmall,
          child: Text(AppLocalizations.of(context).notPicked, style: infoTextStyle),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: defaultTextStyle,
            children: [
              TextSpan(text: AppLocalizations.of(context).convince),
              TextSpan(text: leaderName, style: boldTextStyle),
              TextSpan(text: AppLocalizations.of(context).putYouInTeam),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tokenContinue(String leaderName, bool teamSubmitted) {
    if (teamSubmitted) {
      return _continueButton();
    }
    return Text(
      AppLocalizations.of(context).waitingForTeamSubmission(leaderName),
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  Widget _tokenCard(bool goingOnHaunt, String leaderName, bool teamSubmitted) => Expanded(
        child: Padding(
          padding: paddingMedium,
          child: Card(
            elevation: 6.0,
            child: Padding(
              padding: paddingSmall,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimationListenable<Color>(
                    animation: _pulseAnimation,
                    builder: (context, value, _) => teamSelectionIcon(goingOnHaunt, value, 250.0),
                  ),
                  _waitForTeamMessage(goingOnHaunt, leaderName),
                  Column(
                    children: [
                      _tokenContinue(leaderName, teamSubmitted),
                      Divider(),
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

class _TeamPickerViewModel {
  @required
  Set<Player> team;
  @required
  bool teamSubmitted;
  @required
  bool submittingTeam;

  _TeamPickerViewModel({this.team, this.teamSubmitted, this.submittingTeam});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TeamPickerViewModel &&
          runtimeType == other.runtimeType &&
          team == other.team &&
          teamSubmitted == other.teamSubmitted &&
          submittingTeam == other.submittingTeam;

  @override
  int get hashCode => team.hashCode ^ teamSubmitted.hashCode ^ submittingTeam.hashCode;

  @override
  String toString() {
    return '_TeamPickerViewModel{team: $team, teamSubmitted: $teamSubmitted, submittingTeam: $submittingTeam}';
  }
}

class TeamPickerState extends TeamSelectionState {
  TeamPickerState(Store<GameModel> store) : super(store);

  Widget _actionButton(bool currentTeamIsFull, bool teamSubmitted, bool loading) {
    if (teamSubmitted) {
      return _continueButton();
    }
    return RaisedButton(
      onPressed: currentTeamIsFull && !loading ? () => _store.dispatch(SubmitTeamAction()) : null,
      child: Text(
        AppLocalizations.of(context).submitTeam,
        style: Theme.of(context).textTheme.button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, _TeamPickerViewModel>(
      distinct: true,
      converter: (store) => _TeamPickerViewModel(
            team: currentTeam(store.state),
            teamSubmitted: currentRound(store.state).teamSubmitted,
            submittingTeam: requestInProcess(store.state, Request.SubmittingTeam),
          ),
      onInit: (store) => _setUpPulse(goingOnHaunt(store.state), currentTeamIsFull(store.state)),
      onInitialBuild: (viewModel) => _runContinueButtonAnimation(viewModel.teamSubmitted),
      onWillChange: (_) => _setUpPulse(goingOnHaunt(_store.state), currentTeamIsFull(_store.state)),
      onDidChange: (viewModel) => _runContinueButtonAnimation(viewModel.teamSubmitted),
      builder: (context, viewModel) {
        int playersRequired = currentHaunt(_store.state).numPlayers;
        bool amGoingOnHaunt = goingOnHaunt(_store.state);
        return AnimationListenable<Color>(
          animation: _pulseAnimation,
          builder: (context, value, child) => Container(color: value, child: child),
          staticChild: Column(
            children: [
              _teamPickerCard(
                amGoingOnHaunt,
                viewModel.team,
                playersRequired,
                viewModel.teamSubmitted,
                viewModel.submittingTeam,
              ),
              _ghosties(playersRequired),
            ],
          ),
        );
      });

  Widget _teamPickerCard(bool goingOnHaunt, Set<Player> team, int playersRequired,
          bool teamSubmitted, bool submittingTeam) =>
      Expanded(
        child: Padding(
          padding: paddingMedium,
          child: Card(
            elevation: 6.0,
            child: Padding(
              padding: paddingSmall,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimationListenable<Color>(
                    animation: _pulseAnimation,
                    builder: (context, value, _) => teamSelectionIcon(goingOnHaunt, value, 100.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context).pickATeam(team.length, playersRequired),
                        style: infoTextStyle,
                      ),
                      TeamGridView(
                        _teamPickerChildren(team, playersRequired, teamSubmitted, submittingTeam),
                        childAspectRatio: 4.0,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _actionButton(team.length == playersRequired, teamSubmitted, submittingTeam),
                      Divider(),
                      roundTitleContents(context, _store),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  List<Widget> _teamPickerChildren(
      Set<Player> team, int playersRequired, bool teamSubmitted, bool loading) {
    String roundId = currentRound(_store.state).id;
    List<Player> players = getPlayers(_store.state);
    Player leader = currentLeader(_store.state);
    return List.generate(players.length, (i) {
      Player player = players[i];
      bool isInTeam = team.contains(player);
      bool isLeader = player.id == leader.id;
      bool enabled = (isInTeam || team.length < playersRequired) && !teamSubmitted && !loading;
      return InkWell(
          onTap: enabled ? () => _onTap(_store, roundId, player.id, isInTeam) : null,
          child: playerTile(context, player.name, isInTeam, isLeader));
    });
  }

  void _onTap(Store<GameModel> store, String roundId, String playerId, bool isInTeam) {
    if (isInTeam) {
      store.dispatch(RemovePlayerAction(roundId, playerId));
      store.dispatch(RemovePlayerMiddlewareAction(playerId));
    } else {
      store.dispatch(PickPlayerAction(roundId, playerId));
      store.dispatch(PickPlayerMiddlewareAction(playerId));
    }
  }
}
