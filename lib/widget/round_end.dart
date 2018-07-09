part of heist;

Widget continueRoundButton(Store<GameModel> store) => new RaisedButton(
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
    ..add(new Text('Total pot = ${currentPot(store.state)}', style: infoTextStyle));

  if (amOwner(store.state)) {
    children.add(continueRoundButton(store));
  }

  return new Card(
    elevation: 2.0,
    child: new Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    ),
  );
}