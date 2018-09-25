import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/team_selection_middleware.dart';
import 'package:heist/reducers/local_actions_reducers.dart';
import 'package:heist/reducers/round_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/selection_board.dart';
import 'package:redux/redux.dart';

class Exclusions extends StatefulWidget {
  final Store<GameModel> _store;
  final bool _isMyGo;

  Exclusions(this._store, this._isMyGo);

  @override
  State<StatefulWidget> createState() {
    return _isMyGo ? ExclusionsPickerState(_store) : _WaitForExclusionsState(_store);
  }
}

abstract class ExclusionsState extends State<Exclusions> with TickerProviderStateMixin {
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

  ExclusionsState(this._store);

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

  Animation<Color> _getPulseTween(bool haveBeenExcluded, bool allExclusionsPicked) {
    if (allExclusionsPicked) {
      Color beginColor = haveBeenExcluded ? Colors.redAccent : Colors.green;
      Color endColor = haveBeenExcluded ? HeistColors.peach : HeistColors.green;
      return ColorTween(begin: beginColor, end: endColor).animate(_pulseController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _pulseController.forward();
          }
        });
    }
    return ConstantTween<Color>(haveBeenExcluded ? HeistColors.peach : HeistColors.green)
        .animate(_pulseController);
  }

  @protected
  void _setUpPulse(bool haveBeenExcluded, bool allExclusionsPicked) {
    _pulseController?.dispose();
    _pulseController = null;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = _getPulseTween(haveBeenExcluded, allExclusionsPicked);
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
            child: Text(AppLocalizations.of(context).continueToBidding, style: buttonTextStyle),
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
      converter: (store) => _index < currentExclusions(store.state).length,
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

class _WaitForExclusionsViewModel {
  @required
  bool haveBeenExcluded;
  @required
  bool allExclusionsPicked;
  @required
  bool exclusionsSubmitted;

  _WaitForExclusionsViewModel(
      {this.haveBeenExcluded, this.allExclusionsPicked, this.exclusionsSubmitted});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WaitForExclusionsViewModel &&
          runtimeType == other.runtimeType &&
          haveBeenExcluded == other.haveBeenExcluded &&
          allExclusionsPicked == other.allExclusionsPicked &&
          exclusionsSubmitted == other.exclusionsSubmitted;

  @override
  int get hashCode =>
      haveBeenExcluded.hashCode ^ allExclusionsPicked.hashCode ^ exclusionsSubmitted.hashCode;

  @override
  String toString() {
    return '_WaitForTeamViewModel{haveBeenExcluded: $haveBeenExcluded, allExclusionsPicked: $allExclusionsPicked, exclusionsSubmitted: $exclusionsSubmitted}';
  }
}

class _WaitForExclusionsState extends ExclusionsState {
  _WaitForExclusionsState(Store<GameModel> store) : super(store);

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, _WaitForExclusionsViewModel>(
        distinct: true,
        converter: (store) => _WaitForExclusionsViewModel(
              haveBeenExcluded: haveBeenExcluded(store.state),
              allExclusionsPicked: allExclusionsPicked(store.state),
              exclusionsSubmitted: currentRound(store.state).exclusionsSubmitted,
            ),
        onInit: (store) =>
            _setUpPulse(haveBeenExcluded(store.state), allExclusionsPicked(store.state)),
        onInitialBuild: (viewModel) => _runContinueButtonAnimation(viewModel.exclusionsSubmitted),
        onWillChange: (viewModel) =>
            _setUpPulse(viewModel.haveBeenExcluded, viewModel.allExclusionsPicked),
        onDidChange: (viewModel) => _runContinueButtonAnimation(viewModel.exclusionsSubmitted),
        builder: (context, viewModel) {
          int playersRequired = currentHaunt(_store.state).numPlayers;
          Player leader = currentLeader(_store.state);
          return AnimationListenable<Color>(
            animation: _pulseAnimation,
            builder: (context, value, child) => Container(color: value, child: child),
            staticChild: Column(
              children: [
                _tokenCard(viewModel.haveBeenExcluded, leader.name, viewModel.exclusionsSubmitted),
                _ghosties(playersRequired),
              ],
            ),
          );
        },
      );

  Widget _waitForTeamMessage(bool haveBeenExcluded, String leaderName) {
    const TextStyle defaultTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
    if (haveBeenExcluded) {
      return Column(
        children: [
          Padding(
            padding: paddingSmall,
            child: Text(AppLocalizations.of(context).excluded, style: infoTextStyle),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: defaultTextStyle,
              children: [
                TextSpan(text: AppLocalizations.of(context).convince),
                TextSpan(text: leaderName, style: boldTextStyle),
                TextSpan(text: AppLocalizations.of(context).notToExclude),
              ],
            ),
          ),
        ],
      );
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultTextStyle,
        children: [
          TextSpan(text: leaderName, style: boldTextStyle),
          TextSpan(text: AppLocalizations.of(context).didNotExclude),
        ],
      ),
    );
  }

  Widget _tokenContinue(String leaderName, bool teamSubmitted) {
    if (teamSubmitted) {
      return _continueButton();
    }
    return Text(
      AppLocalizations.of(context).waitingToConfirmExclusions(leaderName),
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  Widget _tokenCard(bool haveBeenExcluded, String leaderName, bool teamSubmitted) => Expanded(
        child: Card(
          margin: paddingMedium,
          elevation: 6.0,
          child: Padding(
            padding: paddingSmall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimationListenable<Color>(
                  animation: _pulseAnimation,
                  builder: (context, value, _) => teamSelectionIcon(haveBeenExcluded, value, 250.0),
                ),
                _waitForTeamMessage(haveBeenExcluded, leaderName),
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
      );
}

class _ExclusionsPickerViewModel {
  @required
  Set<Player> exclusions;
  @required
  bool exclusionsSubmitted;
  @required
  bool submittingExclusions;

  _ExclusionsPickerViewModel(
      {this.exclusions, this.exclusionsSubmitted, this.submittingExclusions});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ExclusionsPickerViewModel &&
          runtimeType == other.runtimeType &&
          exclusions == other.exclusions &&
          exclusionsSubmitted == other.exclusionsSubmitted &&
          submittingExclusions == other.submittingExclusions;

  @override
  int get hashCode =>
      exclusions.hashCode ^ exclusionsSubmitted.hashCode ^ submittingExclusions.hashCode;

  @override
  String toString() {
    return '_TeamPickerViewModel{exclusions: $exclusions, exclusionsSubmitted: $exclusionsSubmitted, submittingExclusions: $submittingExclusions}';
  }
}

class ExclusionsPickerState extends ExclusionsState {
  ExclusionsPickerState(Store<GameModel> store) : super(store);

  Widget _actionButton(bool allExclusionsPicked, bool exclusionsSubmitted, bool loading) {
    if (exclusionsSubmitted) {
      return _continueButton();
    }
    return RaisedButton(
      onPressed:
          allExclusionsPicked && !loading ? () => _store.dispatch(SubmitExclusionsAction()) : null,
      child: Text(AppLocalizations.of(context).submitExclusions, style: buttonTextStyle),
    );
  }

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, _ExclusionsPickerViewModel>(
      distinct: true,
      converter: (store) => _ExclusionsPickerViewModel(
            exclusions: currentExclusions(store.state),
            exclusionsSubmitted: currentRound(store.state).exclusionsSubmitted,
            submittingExclusions: requestInProcess(store.state, Request.SubmittingExclusions),
          ),
      onInit: (store) =>
          _setUpPulse(haveBeenExcluded(store.state), allExclusionsPicked(store.state)),
      onInitialBuild: (viewModel) => _runContinueButtonAnimation(viewModel.exclusionsSubmitted),
      onWillChange: (_) =>
          _setUpPulse(haveBeenExcluded(_store.state), allExclusionsPicked(_store.state)),
      onDidChange: (viewModel) => _runContinueButtonAnimation(viewModel.exclusionsSubmitted),
      builder: (context, viewModel) {
        int exclusionsRequired = getRoom(_store.state).numExclusions;
        bool excluded = haveBeenExcluded(_store.state);
        return AnimationListenable<Color>(
          animation: _pulseAnimation,
          builder: (context, value, child) => Container(color: value, child: child),
          staticChild: Column(
            children: [
              _exclusionsPickerCard(
                excluded,
                viewModel.exclusions,
                exclusionsRequired,
                viewModel.exclusionsSubmitted,
                viewModel.submittingExclusions,
              ),
              _ghosties(exclusionsRequired),
            ],
          ),
        );
      });

  Widget _exclusionsPickerCard(
    bool haveBeenExcluded,
    Set<Player> exclusions,
    int exclusionsRequired,
    bool exclusionsSubmitted,
    bool submittingExclusions,
  ) =>
      Expanded(
        child: Card(
          margin: paddingMedium,
          elevation: 6.0,
          child: Padding(
            padding: paddingSmall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimationListenable<Color>(
                  animation: _pulseAnimation,
                  builder: (context, value, _) => teamSelectionIcon(haveBeenExcluded, value, 100.0),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .pickExclusions(exclusions.length, exclusionsRequired),
                      style: infoTextStyle,
                    ),
                    TeamGridView(
                      _exclusionPickerChildren(
                        exclusions,
                        exclusionsRequired,
                        exclusionsSubmitted,
                        submittingExclusions,
                      ),
                      childAspectRatio: 5.0,
                    ),
                  ],
                ),
                Column(
                  children: [
                    _actionButton(
                      exclusions.length == exclusionsRequired,
                      exclusionsSubmitted,
                      submittingExclusions,
                    ),
                    Divider(),
                    roundTitleContents(context, _store),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> _exclusionPickerChildren(
      Set<Player> team, int exclusionsRequired, bool exclusionsSubmitted, bool loading) {
    String roundId = currentRound(_store.state).id;
    List<Player> players = getPlayers(_store.state);
    Player leader = currentLeader(_store.state);
    return List.generate(players.length, (i) {
      Player player = players[i];
      bool hasBeenExcluded = team.contains(player);
      bool isLeader = player.id == leader.id;
      bool enabled =
          (hasBeenExcluded || team.length < exclusionsRequired) && !exclusionsSubmitted && !loading;
      return InkWell(
          onTap: enabled ? () => _onTap(_store, roundId, player.id, hasBeenExcluded) : null,
          child: playerTile(
            context,
            player.name,
            isLeader,
            hasBeenExcluded,
            Theme.of(context).accentColor,
          ));
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
