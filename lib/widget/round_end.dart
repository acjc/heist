import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/round_end_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

class RoundEnd extends StatefulWidget {
  final Store<GameModel> _store;

  RoundEnd(this._store);

  @override
  State<StatefulWidget> createState() {
    return new _RoundEndState(_store);
  }
}

class _RoundEndState extends State<RoundEnd> with TickerProviderStateMixin {
  static const double _thresholdHeight = 250.0;
  static const double _barWidth = 75.0;
  static const double _labelContainerWidth = 75.0;
  static const double _labelContainerHeight = 100.0;

  static const double _labelFontSize = 50.0;

  final Store<GameModel> _store;

  Animation<double> _potAnimation;
  Animation<Offset> _potLabelAnimation;
  Animation<double> _bidAnimation;
  Animation<Offset> _bidLabelAnimation;

  Animation<double> _fadeAnimation;
  Animation<Decoration> _backgroundAnimation;

  AnimationController _controller;

  _RoundEndState(this._store);

  @override
  initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 4000), vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  void _setUpAnimation(double potBarHeight, double bidBarHeight, Color backgroundColor) {
    _potAnimation = Tween(begin: 1.0, end: potBarHeight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _potLabelAnimation = Tween(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -(potBarHeight / _labelContainerHeight)),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _bidAnimation = Tween(begin: 1.0, end: bidBarHeight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _bidLabelAnimation = Tween(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -(bidBarHeight / _labelContainerHeight)),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _backgroundAnimation = DecorationTween(
            begin: BoxDecoration(color: Colors.transparent),
            end: BoxDecoration(color: backgroundColor))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.repeat();
  }

  @override
  dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Widget _roundContinueButton() => new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingRound),
      distinct: true,
      builder: (context, completingGame) {
        return new Container(
          padding: paddingSmall,
          child: new RaisedButton(
            child: new Text(AppLocalizations.of(context).continueButton, style: buttonTextStyle),
            onPressed: completingGame ? null : () => _store.dispatch(new CompleteRoundAction()),
          ),
        );
      });

  Color _potBarColor(BuildContext context, bool enabled) {
    return /*goingOnHaunt(_store.state) && */ enabled
        ? Theme.of(context).primaryColor
        : Colors.grey;
  }

  int _potBarLabelAmount(int pot, int price, double potBarHeight, double value) {
    if (value <= _thresholdHeight) {
      return ((value / _thresholdHeight) * price).round();
    }
    return ((value / potBarHeight) * pot).round();
  }

  Widget _potBarLabel(int pot, int price, double potBarHeight) => AnimationListenable(
        animation: _potAnimation,
        builder: (context, value, child) {
          int amount = _potBarLabelAmount(pot, price, potBarHeight, value);
          Color color = _potBarColor(context, amount >= price);
          return SlideTransition(
            position: _potLabelAnimation,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toString(),
                    style: new TextStyle(
                      fontSize: _labelFontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text('Pot', style: new TextStyle(color: color)),
                ],
              ),
              width: _labelContainerWidth,
              height: _labelContainerHeight,
            ),
          );
        },
      );

  Widget _potBarBox(int pot, int price, double potBarHeight) => AnimationListenable(
        animation: _potAnimation,
        builder: (context, value, child) {
          int amount = ((value / potBarHeight) * pot).round();
          Color color = _potBarColor(context, amount >= price);
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: paddingMedium,
              width: _barWidth,
              height: value,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                    color: Colors.black45,
                  ),
                ],
                color: color,
              ),
            ),
          );
        },
      );

  Widget _potBar(int pot, int price, double potBarHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _potBarLabel(pot, price, potBarHeight),
        _potBarBox(pot, price, potBarHeight),
        Container(width: _labelContainerWidth),
      ],
    );
  }

  Color _bidBarColor(bool enabled) {
    return /*hauntIsActive(_store.state) && */ enabled
        ? (goingOnHaunt(_store.state) ? HeistColors.green : HeistColors.peach)
        : HeistColors.amber;
  }

  Widget _bidBarBox(int bid, double bidBarHeight) => AnimationListenable(
        animation: _bidAnimation,
        builder: (context, value, child) {
          int amount = ((value / bidBarHeight) * bid).round();
          Color barColor = _bidBarColor(amount == bid);
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: paddingMedium,
              width: _barWidth,
              height: value,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white, width: 3.0)),
                color: barColor,
              ),
            ),
          );
        },
      );

  Widget _bidBarLabel(int bid, double bidLabelMaxOffset) => AnimationListenable(
        animation: _bidLabelAnimation,
        builder: (context, value, child) {
          int ratio = ((value.distance / bidLabelMaxOffset) * bid).round();
          Color barColor = _bidBarColor(ratio == bid);
          return SlideTransition(
            position: _bidLabelAnimation,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratio.toString(),
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                  Text('Your bid', style: TextStyle(color: barColor)),
                ],
              ),
              width: _labelContainerWidth,
              height: _labelContainerHeight,
            ),
          );
        },
      );

  Widget _bidBar(int bid, double bidBarHeight) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: _labelContainerWidth),
          _bidBarBox(bid, bidBarHeight),
          _bidBarLabel(bid, bidBarHeight / _labelContainerHeight),
        ],
      );

  Color _backgroundColor(bool hauntIsActive, bool goingOnHaunt) =>
      /*hauntIsActive */ true
          ? (goingOnHaunt ? HeistColors.green : HeistColors.peach)
          : Colors.transparent;

  Widget _thresholdLine(int price) => Row(
        children: [
          Column(
            children: [
              Text(
                price.toString(),
                style: const TextStyle(fontSize: 32.0, color: HeistColors.amber),
              ),
              Text('Price', style: const TextStyle(color: HeistColors.amber)),
            ],
          ),
          Container(
            margin: paddingMedium,
            height: 1.5,
            width: 225.0,
            color: HeistColors.amber,
          ),
        ],
      );

  Text _headerSummaryText(bool hauntIsActive, bool goingOnHaunt) {
    double fontSize = 16.0;
    return hauntIsActive
        ? (goingOnHaunt
            ? Text("You're going on a haunt!",
                style: TextStyle(fontSize: fontSize, color: HeistColors.green))
            : Text('The haunt is going ahead!',
                style: TextStyle(fontSize: fontSize, color: HeistColors.peach)))
        : Text(
            'Not enough ectoplasm for this haunt!',
            style: TextStyle(fontSize: fontSize, color: HeistColors.blue),
          );
  }

  Widget _headerSummaryIcon(bool hauntIsActive, bool goingOnHaunt) {
    double size = 75.0;
    return hauntIsActive
        ? teamSelectionIcon(
            goingOnHaunt,
            goingOnHaunt ? HeistColors.green : HeistColors.peach,
            size,
          )
        : Icon(Icons.warning, color: HeistColors.blue, size: size);
  }

  Widget _header(Haunt haunt, Round round, bool hauntIsActive, bool goingOnHaunt) {
    return Column(
      children: [
        Padding(
          padding: paddingSmall,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              titleSubtitle(
                AppLocalizations.of(context).hauntTitle(haunt.order),
                AppLocalizations.of(context).roundTitle(round.order),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _headerSummaryIcon(hauntIsActive, goingOnHaunt),
              ),
            ],
          ),
        ),
        Padding(
          padding: paddingTiny,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _headerSummaryText(hauntIsActive, goingOnHaunt),
          ),
        ),
      ],
    );
  }

  double _getPotBarHeight(int pot, int price) {
//    if (hauntIsActive(_store.state)) {
    double boost = min((pot - price) * 20.0, 100.0);
    return _thresholdHeight + boost;
//    }
    return (pot / price) * _thresholdHeight;
  }

  Widget _barStack() {
    Haunt haunt = currentHaunt(_store.state);
    Round round = currentRound(_store.state);
    bool hauntActive = hauntIsActive(_store.state);
    bool amGoingOnHaunt = goingOnHaunt(_store.state);
    int pot = round.pot;
    pot = 13;
//    int bid = myCurrentBid(_store.state).amount;
    int bid = 5;
    Color backgroundColor = _backgroundColor(hauntActive, amGoingOnHaunt);
    double potBarHeight = _getPotBarHeight(pot, haunt.price);
    double bidBarHeight = (bid / pot) * potBarHeight;
    _setUpAnimation(potBarHeight, bidBarHeight, backgroundColor);
    return DecoratedBoxTransition(
      decoration: _backgroundAnimation,
      child: Padding(
        padding: paddingMedium,
        child: Card(
          elevation: 6.0,
          child: Padding(
            padding: paddingTiny,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _header(haunt, round, hauntActive, amGoingOnHaunt),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Positioned(
                        bottom: _thresholdHeight,
                        child: _thresholdLine(haunt.price),
                      ),
                      _potBar(pot, haunt.price, potBarHeight),
                      _bidBar(bid, bidBarHeight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _barStack();
  }

  Widget _roundEndCard() {
    List<Player> players = getPlayers(_store.state);
    Round round = currentRound(_store.state);
    assert(players.length == round.bids.length);

    List<Widget> children = new List.generate(players.length, (i) {
      Player player = players[i];
      return new Container(
        padding: paddingSmall,
        child: new Text(
            AppLocalizations.of(context).playerBid(player.name, round.bids[player.id].amount),
            style: infoTextStyle),
      );
    })
      ..add(
        new Container(
            padding: paddingSmall,
            child: new Text(
                AppLocalizations.of(context).totalPot(round.pot, currentHaunt(_store.state).price),
                style: titleTextStyle)),
      );

    if (amOwner(_store.state)) {
      children.add(_roundContinueButton());
    }

    return new Card(
      elevation: 2.0,
      child: new Container(
        padding: paddingMedium,
        alignment: Alignment.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    );
  }
}
