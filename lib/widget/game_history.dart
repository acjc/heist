part of heist;

Widget _gameHistory(Store<GameModel> store) {
  return new StoreConnector<GameModel, List<Heist>>(
      distinct: true,
      converter: (store) => store.state.heists,
      builder: (context, viewModel) {
        if (!store.state.ready()) {
          return new Container();
        }
        return new Card(
            elevation: 2.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: new List.generate(5, (i) {
                int price = i < viewModel.length ? viewModel[i].price : -1;
                return new Container(
                  padding: padding,
                  child: new Text("$price"),
                );
              }),
            ));
      });
}
