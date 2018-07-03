part of heist;

Widget continueButton(Store<GameModel> store) => new RaisedButton(
      child: const Text('CONTINUE', style: buttonTextStyle),
      onPressed: () => store.dispatch(new CompleteRoundAction()),
    );

Widget roundEnd(Store<GameModel> store) {
  List<Player> players = getPlayers(store.state);
  Map<String, Bid> bids = currentRound(store.state).bids;
  assert(players.length == bids.length);

  List<Widget> children = new List.generate(players.length, (i) {
    Player player = players[i];
    return new Text('${player.name} bid ${bids[player.id].amount}', style: infoTextStyle);
  })
    ..add(new Text('Total pot = ${currentPot(store.state)}'));

  if (amOwner(store.state)) {
    children.add(continueButton(store));
  }

  return new Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: children,
  );
}
