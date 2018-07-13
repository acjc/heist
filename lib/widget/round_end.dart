part of heist;

Widget roundContinueButton(Store<GameModel> store) => new StoreConnector<GameModel, bool>(
      converter: (store) => requestInProcess(store.state, Request.CompletingRound),
      distinct: true,
      builder: (context, completingGame) {
        return new Container(
          padding: paddingSmall,
          child: new RaisedButton(
            child: const Text('CONTINUE', style: buttonTextStyle),
            onPressed: completingGame ? null : () => store.dispatch(new CompleteRoundAction()),
          ),
        );
      });

Widget roundEnd(Store<GameModel> store) {
  List<Player> players = getPlayers(store.state);
  Round round = currentRound(store.state);
  assert(players.length == round.bids.length);

  List<Widget> children = new List.generate(players.length, (i) {
    Player player = players[i];
    return new Container(
      padding: paddingSmall,
      child: new Text('${player.name} bid ${round.bids[player.id].amount}', style: infoTextStyle),
    );
  })
    ..add(
      new Container(
          padding: paddingSmall,
          child: new Text('Total pot = ${round.pot} / ${currentHeist(store.state).price}',
              style: titleTextStyle)),
    );

  if (amOwner(store.state)) {
    children.add(roundContinueButton(store));
  }

  return new Card(
    elevation: 2.0,
    child: new Container(
      padding: paddingMedium,
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    ),
  );
}
