import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/animations/animation_listenable.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/round_end_middleware.dart';
import 'package:heist/reducers/local_actions_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';

class RoundEnd extends StatefulWidget {
  final Store<GameModel> _store;
  final int _roundOrder;

  RoundEnd(this._store, this._roundOrder);

  @override
  State<StatefulWidget> createState() {
    return _RoundEndState(_store, _roundOrder);
  }
}

class _RoundEndState extends State<RoundEnd> with SingleTickerProviderStateMixin {
  /// Height of the bar indicating the price
  static const double _thresholdHeight = 275.0;

  static const double _barWidth = 75.0;
  static const double _labelContainerWidth = 75.0;
  static const double _labelContainerHeight = 100.0;

  static const double _labelFontSize = 50.0;

  final Store<GameModel> _store;
  final int _roundOrder;

  Animation<double> _potAnimation;
  Animation<Offset> _potLabelAnimation;
  Animation<double> _bidAnimation;
  Animation<Offset> _bidLabelAnimation;

  Animation<double> _fadeAnimation;
  Animation<Decoration> _backgroundAnimation;

  AnimationController _controller;

  _RoundEndState(this._store, this._roundOrder);

  @override
  initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 6000), vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.ease),
      ),
    );
    Screen.keepOn(true);
  }

  /// NB. Offset is a scaling factor rather than an absolute value. Negative y offset is upwards.
  void _setUpAnimation(double potBarHeight, double bidBarHeight, Color backgroundResultColor) {
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
            end: BoxDecoration(color: backgroundResultColor))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.ease),
      ),
    );

    _controller.forward();
  }

  @override
  dispose() {
    Screen.keepOn(false);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Widget _continue(Round round) => StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingRound),
      distinct: true,
      builder: (context, completingRound) => RaisedButton(
            child: Text(
              AppLocalizations.of(context).continueButton,
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              if (!round.complete && !completingRound) {
                _store.dispatch(CompleteRoundAction(round.id));
              }
              _store.dispatch(
                  RecordLocalRoundActionAction(round.id, LocalRoundAction.RoundEndContinue));
            },
          ));

  /// Amount of the pot to display as the pot bar grows.
  /// We want the amount to equal the price as the bar crosses the threshold line.
  int _potBarLabelAmount(int pot, int price, double animationUpperBound, double value) {
    if (pot >= price && value <= _thresholdHeight) {
      return ((value / _thresholdHeight) * price).round();
    }
    return ((value / animationUpperBound) * pot).round();
  }

  Color _potBarColor(int amount, int price) =>
      amount >= price ? Theme.of(context).primaryColor : Colors.grey;

  Widget _potBarLabel(int pot, int price, double animationUpperBound) => AnimationListenable(
        animation: _potAnimation,
        builder: (context, value, child) {
          int amount = _potBarLabelAmount(pot, price, animationUpperBound, value);
          Color color = _potBarColor(amount, price);
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
                  Text(AppLocalizations.of(context).pot, style: new TextStyle(color: color)),
                ],
              ),
              width: _labelContainerWidth,
              height: _labelContainerHeight,
            ),
          );
        },
      );

  Widget _potBarBox(int pot, int price, double animationUpperBound) => Align(
        alignment: Alignment.bottomCenter,
        child: AnimationListenable(
          animation: _potAnimation,
          builder: (context, value, child) {
            int amount = ((value / animationUpperBound) * pot).round();
            Color color = _potBarColor(amount, price);
            return Container(
              margin: paddingMedium,
              width: _barWidth,
              height: value,
              decoration: BoxDecoration(
                boxShadow: barShadow,
                color: color,
              ),
            );
          },
        ),
      );

  Widget _potBar(int pot, int price, double animationUpperBound) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _potBarLabel(pot, price, animationUpperBound),
          _potBarBox(pot, price, animationUpperBound),
          Container(width: _labelContainerWidth),
        ],
      );

  Color _bidBarColor(int amount, int price, Color color) => amount >= price ? color : Colors.amber;

  Widget _bidBarBox(int pot, int price, double animationUpperBound, Color color) => Align(
        alignment: Alignment.bottomCenter,
        child: AnimationListenable(
          animation: _bidAnimation,
          builder: (context, value, child) {
            // Change colour when the pot bar reaches the price
            int potLabelAmount =
                _potBarLabelAmount(pot, price, animationUpperBound, _potAnimation.value).round();
            Color barColor = _bidBarColor(potLabelAmount, price, color);
            return Container(
              margin: paddingMedium,
              width: _barWidth,
              height: value,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white, width: 3.0)),
                color: barColor,
              ),
            );
          },
        ),
      );

  Widget _bidBarLabel(int bid, int pot, int price, double animationUpperBound, Color color) =>
      AnimationListenable(
        animation: _potAnimation,
        builder: (context, value, child) {
          int bidLabelAmount = ((value / animationUpperBound) * bid).round();

          // Change colour when the pot bar reaches the price
          int potLabelAmount = _potBarLabelAmount(pot, price, animationUpperBound, value).round();
          Color barColor = _bidBarColor(potLabelAmount, price, color);
          return SlideTransition(
            position: _bidLabelAnimation,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bidLabelAmount.toString(),
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                  Text(AppLocalizations.of(context).yourBid, style: TextStyle(color: barColor)),
                ],
              ),
              width: _labelContainerWidth,
              height: _labelContainerHeight,
            ),
          );
        },
      );

  Widget _bidBar(int bid, int pot, int price, double animationUpperBound, Color resultColor) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: _labelContainerWidth),
          _bidBarBox(pot, price, animationUpperBound, resultColor),
          _bidBarLabel(bid, pot, price, animationUpperBound, resultColor),
        ],
      );

  Color _backgroundResultColor(bool hauntIsActive, bool goingOnHaunt) =>
      hauntIsActive ? (goingOnHaunt ? HeistColors.green : HeistColors.peach) : Colors.transparent;

  Widget _thresholdLine(int price) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            children: [
              Text(
                price.toString(),
                style: const TextStyle(fontSize: 32.0, color: HeistColors.amber),
              ),
              Text(
                AppLocalizations.of(context).price,
                style: const TextStyle(color: HeistColors.amber),
              ),
            ],
          ),
          Container(
            margin: paddingMedium,
            height: 1.0,
            width: 225.0,
            color: HeistColors.amber,
          ),
        ],
      );

  Text _headerSummaryText(bool hauntIsActive, bool goingOnHaunt) {
    double fontSize = 16.0;
    Color color = hauntIsActive
        ? (goingOnHaunt ? HeistColors.green : HeistColors.peach)
        : Theme.of(context).primaryColor;
    TextStyle textStyle = TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color);
    return hauntIsActive
        ? (goingOnHaunt
            ? Text(AppLocalizations.of(context).youAreGoing, style: textStyle)
            : Text(AppLocalizations.of(context).goingAhead, style: textStyle))
        : Text(AppLocalizations.of(context).notEnough, style: textStyle);
  }

  Widget _headerSummaryIcon(bool hauntIsActive, bool goingOnHaunt) {
    double size = 75.0;
    return hauntIsActive
        ? teamSelectionIcon(
            goingOnHaunt,
            goingOnHaunt ? HeistColors.green : HeistColors.peach,
            size,
          )
        : Icon(Icons.warning, color: Theme.of(context).primaryColor, size: size);
  }

  Widget _header(Haunt haunt, Round round, bool hauntIsActive, bool goingOnHaunt) => Column(
        children: [
          Padding(
            padding: paddingTiny,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleSubtitle(
                  context,
                  AppLocalizations.of(context).hauntTitle(haunt.order),
                  round.isAuction
                      ? AppLocalizations.of(context).auctionTitle
                      : AppLocalizations.of(context).roundTitle(round.order),
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: _continue(round),
          ),
        ],
      );

  /// If the haunt is going ahead, we want the pot bar to proportionally exceed the threshold
  /// line when it grows.
  double _getPotBarHeight(int pot, int price, bool hauntIsActive) {
    if (hauntIsActive) {
      double boost = min((pot - price) * 20.0, 100.0);
      return _thresholdHeight + boost;
    }
    return (pot / price) * _thresholdHeight;
  }

  Color _bidBarResultColor(bool hauntIsActive, bool goingOnHaunt) =>
      hauntIsActive ? (goingOnHaunt ? HeistColors.green : HeistColors.peach) : HeistColors.amber;

  Widget _barStack() {
    Player me = getSelf(_store.state);
    Haunt haunt = currentHaunt(_store.state);
    Round round = roundByOrder(getRounds(_store.state), haunt, _roundOrder);
    int price = haunt.price;
    bool hauntActive = currentHauntIsActive(_store.state);
    bool goingOnHaunt = round.team.contains(me.id);
    int pot = round.pot;
    int bid = round.bids[me.id].amount;

    Color backgroundResultColor = _backgroundResultColor(hauntActive, goingOnHaunt);
    double potBarHeight = _getPotBarHeight(pot, price, hauntActive);
    double bidBarHeight = (bid / pot) * potBarHeight;
    _setUpAnimation(potBarHeight, bidBarHeight, backgroundResultColor);
    return DecoratedBoxTransition(
      decoration: _backgroundAnimation,
      child: Padding(
        padding: paddingMedium,
        child: GameCard(
          child: Padding(
            padding: paddingTiny,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _header(haunt, round, hauntActive, goingOnHaunt),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Positioned(
                        bottom: _thresholdHeight,
                        child: _thresholdLine(price),
                      ),
                      _potBar(pot, price, potBarHeight),
                      _bidBar(
                        bid,
                        pot,
                        price,
                        potBarHeight,
                        _bidBarResultColor(hauntActive, goingOnHaunt),
                      ),
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
    if (!gameIsReady(_store.state)) {
      return loading();
    }
    return _barStack();
  }
}
