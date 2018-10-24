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

const TextStyle descriptionTextStyle = const TextStyle(fontSize: 14.0);
const TextStyle infoTextStyle = const TextStyle(fontSize: 16.0);
const TextStyle boldTextStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
const TextStyle bigNumberTextStyle = const TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300);
const TextStyle titleTextStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
const TextStyle subtitleTextStyle = const TextStyle(fontSize: 13.0);
const TextStyle buttonTextStyle = const TextStyle(color: Colors.black87, fontSize: 16.0);
const TextStyle buttonTextStyleLight = const TextStyle(color: Colors.white, fontSize: 16.0);
const TextStyle chipTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

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

/// Most of our cards use the same elevation
class GameCard extends Card {
  GameCard({
    @required Widget child,
    double elevation = 2.0,
    EdgeInsets margin,
  }) : super(
          elevation: elevation,
          child: child,
          margin: margin,
        );
}

/// Card with a title banner in the top-left corner
class TitledCard extends StatelessWidget {
  static const double defaultMargin = 4.0;

  @required
  final String title;
  @required
  final Widget child;
  final double elevation;
  final EdgeInsets margin;

  TitledCard({
    this.title,
    this.child,
    this.elevation,
    this.margin = const EdgeInsets.all(defaultMargin),
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          GameCard(
            elevation: elevation,
            margin: margin,
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: child,
            ),
          ),
          Positioned(
            top: 12.0 + margin.top,
            left: margin.left - defaultMargin,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Text(title, style: Theme.of(context).textTheme.subhead),
              decoration: BoxDecoration(
                boxShadow: tileShadow,
                borderRadius: BorderRadius.circular(8.0),
                color: HeistColors.purple,
              ),
            ),
          )
        ],
      );
}

/// Collapsible card with a large title across the top
class HeaderCard extends StatelessWidget {
  @required
  final String title;
  @required
  final Widget child;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;

  HeaderCard({
    this.title,
    this.child,
    this.expanded = true,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) => GameCard(
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    // Match the height of the ExpansionTile title
                    child: ListTile(title: Text('')),
                    decoration: BoxDecoration(
                      boxShadow: tileShadow,
                      color: HeistColors.blue,
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: expanded,
              onExpansionChanged: onExpansionChanged,
              leading: Icon(Icons.help_outline, color: HeistColors.amber),
              title: Container(
                alignment: Alignment.center,
                child: Text(title, style: Theme.of(context).textTheme.title),
              ),
              children: [
                Padding(
                  padding: paddingMedium,
                  child: child,
                ),
              ],
            )
          ],
        ),
      );
}

/// A tappable icon, e.g. left and right arrows
Widget iconWidget(BuildContext context, IconData icon, Function onPressed, [bool enabled = true]) =>
    IconButton(
      iconSize: 64.0,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, color: enabled ? Theme.of(context).iconTheme.color : Colors.grey),
    );

Widget loading() => Center(child: CircularProgressIndicator());

Widget centeredTitle(String text) =>
    Center(child: Text(text, style: titleTextStyle, textAlign: TextAlign.center));

/// Text color for a haunt decision
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
      width: 0.5,
      color: color ?? Theme.of(context).dividerColor,
      margin: const EdgeInsets.only(left: 6.0, right: 6.0),
    );
  }
}

/// Icon to indicate whether the player has been picked on a team
Widget teamSelectionIcon(bool goingOnHaunt, Color color, double size) => goingOnHaunt
    ? Icon(Icons.check_circle, color: color, size: size)
    : Icon(Icons.do_not_disturb_alt, color: color, size: size);

/// Two lines of text aligned vertically in a title followed by subtitle combination
Widget titleSubtitle(BuildContext context, String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.subhead),
        Text(subtitle, style: Theme.of(context).textTheme.caption),
      ],
    );

Widget roundTitleIcon(IconData icon, String text) => iconText(
      Icon(icon, size: 32.0),
      Text(text, style: infoTextStyle),
    );

Widget roundTitleContents(BuildContext context, Store<GameModel> store) {
  Haunt haunt = currentHaunt(store.state);
  Round round = currentRound(store.state);
  String subtitle = round.isAuction
      ? AppLocalizations.of(context).auctionTitle
      : AppLocalizations.of(context).roundTitle(round.order);

  List<Widget> children = [
    titleSubtitle(context, AppLocalizations.of(context).hauntTitle(haunt.order), subtitle),
    VerticalDivider(),
    roundTitleIcon(Icons.people, haunt.numPlayers.toString()),
    roundTitleIcon(Icons.bubble_chart, haunt.price.toString()),
    roundTitleIcon(Icons.vertical_align_top, haunt.maximumBid.toString()),
  ];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: children,
  );
}

/// Card describing the current haunt and round
Widget roundTitleCard(BuildContext context, Store<GameModel> store) => TitledCard(
      title: AppLocalizations.of(context).hauntInfo,
      child: Padding(
        padding: paddingSmall,
        child: roundTitleContents(context, store),
      ),
    );

/// Widget for showing a 2-column grid
class TeamGridView extends GridView {
  TeamGridView(List<Widget> children, {double childAspectRatio = 5.0})
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

/// Text with an adjacent icon. Use 'trailingIcon' to put the icon on the right-hand side.
Widget iconText(Icon icon, Text text, {bool trailingIcon = false}) {
  List<Widget> children = [];
  if (trailingIcon) {
    children.addAll([
      text,
      Container(
        child: icon,
        margin: const EdgeInsets.only(left: 4.0),
      )
    ]);
  } else {
    children.addAll([
      Container(
        child: icon,
        margin: const EdgeInsets.only(right: 4.0),
      ),
      text,
    ]);
  }
  return Row(
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
          return Future(() async {
            _goBackToMainPage(context);
            return false;
          });
        },
        child: AlertDialog(
          key: Keys.noConnectionDialogKey,
          title: Text(AppLocalizations.of(context).noConnectionDialogTitle),
          content: Text(AppLocalizations.of(context).noConnectionDialogText),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).okButton),
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
