part of heist;

const EdgeInsets selectionBoardPadding = const EdgeInsets.all(16.0);

Widget selectionBoard() => new StoreConnector<GameModel, Set<String>>(
    converter: (store) => teamSelection(store.state),
    distinct: true,
    builder: (context, teamSelection) => new Card(
          elevation: 2.0,
          child: new Container(
              padding: selectionBoardPadding,
              child: new Column(children: [
                new Text('TEAM', style: textStyle),
                new GridView.count(
                    padding: selectionBoardPadding,
                    shrinkWrap: true,
                    childAspectRatio: 6.0,
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: new List.generate(
                        teamSelection.length,
                        (i) => new Container(
                            alignment: Alignment.center,
                            decoration: new BoxDecoration(
                              border: new Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: new Text(
                              teamSelection.elementAt(i),
                              style: textStyle,
                            ))))
              ])),
        ));
