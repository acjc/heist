import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/keys.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

const EdgeInsets paddingLarge = const EdgeInsets.all(24.0);
const EdgeInsets paddingMedium = const EdgeInsets.all(16.0);
const EdgeInsets paddingSmall = const EdgeInsets.all(12.0);
const EdgeInsets paddingTiny = const EdgeInsets.all(8.0);
const EdgeInsets paddingNano = const EdgeInsets.all(4.0);
const EdgeInsets paddingTitle = const EdgeInsets.only(bottom: 12.0);
const EdgeInsets paddingBelowText = const EdgeInsets.only(bottom: 4.0);

const TextStyle infoTextStyle = const TextStyle(fontSize: 16.0);
const TextStyle boldTextStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
const TextStyle bigNumberTextStyle = const TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300);
const TextStyle titleTextStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
const TextStyle subtitleTextStyle = const TextStyle(color: Colors.white54);
const TextStyle buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 16.0);
const TextStyle chipTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

const TextStyle infoTextStyleDark = const TextStyle(fontSize: 16.0, color: Colors.black87);
const TextStyle boldTextStyleDark = const TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
const TextStyle bigNumberTextStyleDark = const TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.w300,
  color: Colors.black87,
);
const TextStyle titleTextStyleDark = const TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
const TextStyle subtitleTextStyleDark = const TextStyle(color: Colors.black54);

/// elevation: 1.0
const List<BoxShadow> tileShadow = [
  BoxShadow(
      offset: Offset(0.0, 2.0), blurRadius: 1.0, spreadRadius: -1.0, color: HeistColors.umbra),
  BoxShadow(
      offset: Offset(0.0, 1.0), blurRadius: 1.0, spreadRadius: 0.0, color: HeistColors.penumbra),
  BoxShadow(
      offset: Offset(0.0, 1.0), blurRadius: 3.0, spreadRadius: 0.0, color: HeistColors.ambient),
];

/// elevation: 4.0
const List<BoxShadow> barShadow = [
  BoxShadow(
      offset: Offset(0.0, 2.0), blurRadius: 4.0, spreadRadius: -1.0, color: HeistColors.umbra),
  BoxShadow(
      offset: Offset(0.0, 4.0), blurRadius: 5.0, spreadRadius: 0.0, color: HeistColors.penumbra),
  BoxShadow(
      offset: Offset(0.0, 1.0), blurRadius: 10.0, spreadRadius: 0.0, color: HeistColors.ambient),
];

class DarkCard extends Card {
  DarkCard({
    @required Widget child,
    double elevation = 2.0,
    EdgeInsets margin,
  }) : super(
          elevation: elevation,
          color: Colors.black12,
          child: child,
          margin: margin,
        );
}

Widget iconWidget(BuildContext context, IconData icon, Function onPressed, [bool enabled = true]) {
  Color color = Theme.of(context).primaryColor;
  return new IconButton(
    iconSize: 64.0,
    onPressed: enabled ? onPressed : null,
    icon: new Icon(icon, color: enabled ? color : Colors.grey),
  );
}

Widget centeredMessage(String text) {
  return new Center(child: new Text(text, style: infoTextStyle));
}

Widget loading() {
  return new Center(child: new CircularProgressIndicator());
}

Color decisionColour(String decision) {
  switch (decision) {
    case 'SCARE':
      return HeistColors.green;
    case 'TICKLE':
      return HeistColors.peach;
    case 'STEAL':
      return HeistColors.amber;
  }
  throw ArgumentError.value(decision, 'decision', 'Unknown decision');
}

class VerticalDivider extends StatelessWidget {
  final double height;
  final Color color;

  VerticalDivider({this.height = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 0.2,
      color: color ?? Theme.of(context).dividerColor,
      margin: const EdgeInsets.only(left: 6.0, right: 6.0),
    );
  }
}

Widget teamSelectionIcon(bool goingOnHaunt, Color color, double size) {
  return goingOnHaunt
      ? new Icon(Icons.check_circle, color: color, size: size)
      : new Icon(Icons.do_not_disturb_alt, color: color, size: size);
}

Widget roundTitleIcon(IconData icon, String text) {
  return iconText(
    new Icon(icon, size: 32.0),
    new Text(text, style: infoTextStyle),
  );
}

Widget titleSubtitle(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      new Text(title, style: boldTextStyle),
      new Text(subtitle, style: subtitleTextStyle),
    ],
  );
}

Widget roundTitleContents(BuildContext context, Store<GameModel> store) {
  Haunt haunt = currentHaunt(store.state);
  Round round = currentRound(store.state);
  String subtitle = round.isAuction
      ? AppLocalizations.of(context).auctionTitle
      : AppLocalizations.of(context).roundTitle(round.order);

  List<Widget> children = [
    titleSubtitle(AppLocalizations.of(context).hauntTitle(haunt.order), subtitle),
    new VerticalDivider(),
    roundTitleIcon(Icons.people, haunt.numPlayers.toString()),
    roundTitleIcon(Icons.bubble_chart, haunt.price.toString()),
    roundTitleIcon(Icons.vertical_align_top, haunt.maximumBid.toString()),
  ];

  return new Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: children,
  );
}

Widget roundTitleCard(BuildContext context, Store<GameModel> store) => new Card(
      elevation: 2.0,
      child: new Padding(
        padding: paddingSmall,
        child: roundTitleContents(context, store),
      ),
    );

/// Widget for showing a 2-column grid
class TeamGridView extends GridView {
  TeamGridView(List<Widget> children, {double childAspectRatio = 6.0})
      : super.count(
          padding: paddingMedium,
          shrinkWrap: true,
          childAspectRatio: childAspectRatio,
          crossAxisCount: 2,
          primary: false,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: children,
        );
}

Widget iconText(Icon icon, Text text, {bool trailingIcon = false}) {
  List<Widget> children = [];
  if (trailingIcon) {
    children.addAll([
      text,
      new Container(
        child: icon,
        margin: const EdgeInsets.only(left: 4.0),
      )
    ]);
  } else {
    children.addAll([
      new Container(
        child: icon,
        margin: const EdgeInsets.only(right: 4.0),
      ),
      text,
    ]);
  }
  return new Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );
}

Future<Null> showNoConnectionDialog(BuildContext context) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // not dismissable
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          // intercept back button and go to home page when tapped
          return new Future(() async {
            _goBackToMainPage(context);
            return false;
          });
        },
        child: new AlertDialog(
          key: Keys.noConnectionDialogKey,
          title: new Text(AppLocalizations.of(context).noConnectionDialogTitle),
          content: new Text(AppLocalizations.of(context).noConnectionDialogText),
          actions: <Widget>[
            new FlatButton(
              child: new Text(AppLocalizations.of(context).okButton),
              onPressed: () {
                _goBackToMainPage(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

_goBackToMainPage(BuildContext context) {
  Navigator.popUntil(context, ModalRoute.withName('/'));
}
