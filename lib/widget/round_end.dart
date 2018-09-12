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
  static const double _barHeight = 350.0;
  static const double _barWidth = 75.0;
  static const double _labelContainerWidth = 75.0;
  static const double _labelContainerHeight = 100.0;
  static const double _potLabelMaxOffset = _barHeight / _labelContainerHeight;

  static const double _fontSize = 50.0;

  final Store<GameModel> _store;

  Animation<double> _potAnimation;
  Animation<Offset> _potLabelAnimation;
  Animation<double> _bidAnimation;
  Animation<Offset> _bidLabelAnimation;
  AnimationController _controller;

  _RoundEndState(this._store);

  @override
  initState() {
    super.initState();
    _controller =
        new AnimationController(duration: const Duration(milliseconds: 4000), vsync: this);
    _potAnimation = new Tween(begin: 1.0, end: _barHeight)
        .animate(new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _potLabelAnimation = new Tween(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -_potLabelMaxOffset),
    ).animate(new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  void _setUpBidAnimation(double barHeight, double labelMaxOffset) {
    _bidAnimation = new Tween(begin: 1.0, end: barHeight)
        .animate(new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _bidLabelAnimation = new Tween(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -labelMaxOffset),
    ).animate(new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
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

  Widget _potBarLabel(int pot, int price) => AnimationListenable(
        animation: _potLabelAnimation,
        builder: (context, value, child) {
          int ratio = ((value.distance / _potLabelMaxOffset) * pot).round();
          Color color = _potBarColor(context, ratio >= price);
          return SlideTransition(
            position: _potLabelAnimation,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ratio.toString(),
                    style: new TextStyle(
                      fontSize: _fontSize,
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

  Widget _potBarBox(int pot, int price) => AnimationListenable(
        animation: _potAnimation,
        builder: (context, value, child) {
          int ratio = ((value / _barHeight) * pot).round();
          Color color = _potBarColor(context, ratio >= price);
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

  Widget _potBar(int pot, int price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _potBarLabel(pot, price),
        _potBarBox(pot, price),
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
          int ratio = ((value / bidBarHeight) * bid).round();
          Color barColor = _bidBarColor(ratio == bid);
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
                      fontSize: _fontSize,
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

  Widget _bidBar(int bid, double bidBarHeight, double bidLabelMaxOffset) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: _labelContainerWidth),
          _bidBarBox(bid, bidBarHeight),
          _bidBarLabel(bid, bidLabelMaxOffset),
        ],
      );

  Decoration _backgroundDecoration() {
    return hauntIsActive(_store.state)
        ? BoxDecoration(color: goingOnHaunt(_store.state) ? HeistColors.green : HeistColors.peach)
        : null;
  }

  Widget _barStack() {
    Haunt haunt = currentHaunt(_store.state);
    Round round = currentRound(_store.state);
    int pot = round.pot;
    pot = 27;
//    int bid = myCurrentBid(_store.state).amount;
    int bid = 9;
    Decoration background = _backgroundDecoration();
    double bidBarHeight = (bid / pot) * _barHeight;
    double bidLabelMaxOffset = bidBarHeight / _labelContainerHeight;
    _setUpBidAnimation(bidBarHeight, bidLabelMaxOffset);
    return Container(
      padding: paddingLarge,
      decoration: background,
      child: Card(
        elevation: 6.0,
        child: Padding(
          padding: paddingTiny,
          child: Stack(
            children: [
              _potBar(pot, haunt.price),
              _bidBar(bid, bidBarHeight, bidLabelMaxOffset),
            ],
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
