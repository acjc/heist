import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

const EdgeInsets paddingLarge = const EdgeInsets.all(24.0);
const EdgeInsets paddingMedium = const EdgeInsets.all(16.0);
const EdgeInsets paddingSmall = const EdgeInsets.all(12.0);
const EdgeInsets paddingTiny = const EdgeInsets.all(8.0);
const EdgeInsets paddingTitle = const EdgeInsets.only(bottom: 12.0);

const TextStyle infoTextStyle = const TextStyle(fontSize: 16.0);
const TextStyle boldTextStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
const TextStyle bigNumberTextStyle = const TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300);
const TextStyle titleTextStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
const TextStyle subtitleTextStyle = const TextStyle(color: Colors.black54);
const TextStyle buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 16.0);
const TextStyle chipTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

Widget iconWidget(BuildContext context, IconData icon, Function onPressed) {
  Color color = Theme.of(context).primaryColor;
  return new IconButton(
    iconSize: 64.0,
    onPressed: onPressed,
    icon: new Icon(icon, color: color),
  );
}

Widget centeredMessage(String text) {
  return new Center(
      child: new Text(
    text,
    style: infoTextStyle,
  ));
}

Widget loading(BuildContext context) {
  return centeredMessage(AppLocalizations.of(context).loading);
}

Color decisionColour(String decision) {
  switch (decision) {
    case 'SUCCEED':
      return Colors.green;
    case 'FAIL':
      return Colors.red;
    case 'STEAL':
      return Colors.blue;
  }
  throw new ArgumentError.value(decision, 'decision', 'Unknown decision');
}

class VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 50.0,
      width: 1.0,
      color: Colors.grey,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }
}

Widget roundTitle(BuildContext context, Store<GameModel> store) {
  Round round = currentRound(store.state);
  String subtitle = round.isAuction
      ? AppLocalizations.of(context).auctionTitle
      : AppLocalizations.of(context).roundTitle(round.order);
  return new Card(
    elevation: 2.0,
    child: new ListTile(
      title: new Text(
        AppLocalizations.of(context).heistTitle(currentHeist(store.state).order),
        style: boldTextStyle,
      ),
      subtitle: new Text(subtitle),
    ),
  );
}
