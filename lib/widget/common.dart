import 'package:flutter/material.dart';
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
  return new Center(child: new Text(text, style: infoTextStyle));
}

Widget loading() {
  return new Center(child: new CircularProgressIndicator());
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
  final double height;

  VerticalDivider({this.height = 50.0});

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: height,
      width: 0.2,
      color: Colors.grey,
      margin: const EdgeInsets.only(left: 6.0, right: 6.0),
    );
  }
}

Widget roundTitle(Store<GameModel> store) {
  Round round = currentRound(store.state);
  String subtitle = round.isAuction ? 'Auction!' : 'Round ${round.order}';
  return new Card(
    elevation: 2.0,
    child: new ListTile(
      title: new Text(
        'Heist ${currentHeist(store.state).order}',
        style: boldTextStyle,
      ),
      subtitle: new Text(subtitle),
    ),
  );
}

/// Widget for showing a 2-column grid
class HeistGridView extends GridView {
  HeistGridView(List<Widget> children, [double childAspectRatio])
      : super.count(
          padding: paddingMedium,
          shrinkWrap: true,
          childAspectRatio: childAspectRatio ?? 6.0,
          crossAxisCount: 2,
          primary: false,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: children,
        );
}

Widget iconText(Icon icon, Text text) => new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        new Container(
          child: icon,
          margin: const EdgeInsets.only(right: 4.0),
        ),
        text,
      ],
    );
