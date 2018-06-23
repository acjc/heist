part of heist;

Widget teamPicker(Store<GameModel> store) {
  return new StoreConnector<GameModel, List<Player>>(
    converter: (store) => getPlayers(store.state),
    distinct: true,
    builder: (context, players) {
      // TODO: grid of flat buttons plus submit button
    }
  );
}