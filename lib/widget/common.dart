part of heist;

Widget iconWidget(BuildContext context, IconData icon, Function onPressed) {
  Color color = Theme.of(context).primaryColor;
  return new IconButton(
    iconSize: 64.0,
    onPressed: onPressed,
    icon: new Icon(icon, color: color),
  );
}
