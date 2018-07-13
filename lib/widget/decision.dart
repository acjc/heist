part of heist;

Widget observeHeist(Store<GameModel> store) {
  return new StoreConnector<GameModel, Map<String, String>>(
      converter: (store) => currentHeist(store.state).decisions,
      distinct: true,
      builder: (context, decisions) {
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                child: new Column(children: [
                  const Text('Heist in progress...', style: infoTextStyle),
                  new GridView.count(
                    padding: paddingMedium,
                    shrinkWrap: true,
                    childAspectRatio: 6.0,
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: observeHeistChildren(context, playersInTeam(store.state), decisions),
                  )
                ])));
      });
}

List<Widget> observeHeistChildren(
    BuildContext context, Set<Player> team, Map<String, String> decisions) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(team.length, (i) {
    Player player = team.elementAt(i);
    bool decisionMade = decisions[player.id] != null;
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            border: new Border.all(color: color), color: decisionMade ? color : null),
        child: new Text(
          player.name,
          style: new TextStyle(fontSize: 16.0, color: decisionMade ? Colors.white : null),
        ));
  });
}

Widget makeDecision(BuildContext context, Store<GameModel> store) =>
    new StoreConnector<GameModel, Map<String, String>>(
        converter: (store) => currentHeist(store.state).decisions,
        distinct: true,
        builder: (context, decisions) {
          Player me = getSelf(store.state);
          List<Widget> children = [];
          if (decisions.containsKey(me.id)) {
            return observeHeist(store);
          } else {
            children.addAll([
              new Container(
                padding: paddingSmall,
                child: const Text('Make your choice', style: titleTextStyle),
              ),
              decisionButton(context, store, 'SUCCEED'),
            ]);
            if (me.role != 'KINGPIN') {
              children.add(decisionButton(context, store, 'STEAL'));
            }
            if (getTeam(me.role) == Team.AGENTS) {
              children.add(decisionButton(context, store, 'FAIL'));
            }
          }
          return new Card(
              elevation: 2.0,
              child: new Container(
                  padding: paddingMedium,
                  alignment: Alignment.center,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)));
        });

Widget decisionButton(BuildContext context, Store<GameModel> store, String decision) =>
    new Container(
        padding: paddingSmall,
        child: new RaisedButton(
          onPressed: () => store.dispatch(new MakeDecisionAction(decision)),
          child: new Text(decision, style: buttonTextStyle),
        ));
