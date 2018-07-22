import 'package:flutter/material.dart';

const EdgeInsets paddingLarge = const EdgeInsets.all(24.0);
const EdgeInsets paddingMedium = const EdgeInsets.all(16.0);
const EdgeInsets paddingSmall = const EdgeInsets.all(12.0);
const EdgeInsets paddingTitle = const EdgeInsets.only(bottom: 12.0);

const TextStyle infoTextStyle = const TextStyle(fontSize: 16.0);
const TextStyle titleTextStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
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

Widget loading() {
  return centeredMessage('Loading...');
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
