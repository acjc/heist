part of heist;

const EdgeInsets paddingLarge = const EdgeInsets.all(24.0);
const EdgeInsets paddingMedium = const EdgeInsets.all(16.0);
const TextStyle infoTextStyle = const TextStyle(fontSize: 16.0);
const TextStyle buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 16.0);

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
