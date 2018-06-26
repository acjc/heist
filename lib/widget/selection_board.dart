part of heist;

Widget teamIsBeingPicked() => new StoreConnector<GameModel, Player>(
    converter: (store) => roundLeader(store.state),
    distinct: true,
    builder: (context, roundLeader) => new Column(children: [
          new Card(
              elevation: 2.0,
              child: new Container(
                  padding: paddingLarge,
                  child: centeredMessage('${roundLeader.name} is picking a team...'))),
          selectionBoard(),
        ]));

Widget selectionBoard() => new StoreConnector<GameModel, Set<String>>(
    converter: (store) => teamNames(store.state),
    distinct: true,
    builder: (context, teamNames) => new Card(
          elevation: 2.0,
          child: new Container(
              padding: paddingMedium,
              child: new Column(children: [
                new Text('TEAM (${teamNames.length})', style: infoTextStyle),
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
