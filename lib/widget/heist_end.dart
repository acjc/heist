part of heist;

Widget heistContinueButton(Store<GameModel> store) {
  return new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingHeist),
      distinct: true,
      builder: (context, completingHeist) => new RaisedButton(
        child: const Text('CONTINUE', style: buttonTextStyle),
        onPressed: completingHeist ? null : () => store.dispatch(new CompleteHeistAction()),
      ));
}

Widget heistEnd(Store<GameModel> store) {
  Set<Player> team = playersInTeam(store.state);
  Map<String, String> decisions = currentHeist(store.state).decisions;
  List<Widget> children = new List.generate(team.length, (i) {
    Player player = team.elementAt(i);
    return new Text('${player.name} -> ${decisions[player.id]}', style: infoTextStyle);
  });

  if (amOwner(store.state)) {
    children.add(heistContinueButton(store));
  }

  return new Card(
    elevation: 2.0,
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    ),
  );
}
