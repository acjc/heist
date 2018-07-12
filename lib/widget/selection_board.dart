part of heist;

Widget waitForTeam(Store<GameModel> store) => new Column(children: [
      new Card(
          elevation: 2.0,
          child: new Container(
              padding: paddingLarge,
              child: centeredMessage('${roundLeader(store.state).name} is picking a team...'))),
      selectionBoard(store),
    ]);

Widget selectionBoard(Store<GameModel> store) => new StoreConnector<GameModel, Set<String>>(
    converter: (store) => teamNames(store.state),
    distinct: true,
    builder: (context, teamNames) => new Card(
          elevation: 2.0,
          child: new Container(
              padding: paddingMedium,
              child: new Column(children: [
                new Container(
                  padding: paddingTitle,
                  child: new Text('TEAM (${currentHeist(store.state).numPlayers})',
                      style: titleTextStyle),
                ),
                new GridView.count(
                    padding: paddingMedium,
                    shrinkWrap: true,
                    childAspectRatio: 6.0,
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: selectionBoardChildren(context, teamNames))
              ])),
        ));

List<Widget> selectionBoardChildren(BuildContext context, Set<String> teamNames) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(
      teamNames.length,
      (i) => new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            border: new Border.all(color: color),
          ),
          child: new Text(
            teamNames.elementAt(i),
            style: infoTextStyle,
          )));
}
