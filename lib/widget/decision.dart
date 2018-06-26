part of heist;

Widget activeHeist() {
  return new StoreConnector<GameModel, ActiveHeistViewModel>(
      converter: (store) => new ActiveHeistViewModel._(
          playersInTeam(store.state), currentHeist(store.state).decisions),
      distinct: true,
      builder: (context, viewModel) {
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
                    children: activeHeistChildren(context, viewModel),
                  )
                ])));
      });
}

List<Widget> activeHeistChildren(BuildContext context, ActiveHeistViewModel viewModel) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(viewModel.playersInTeam.length, (i) {
    Player player = viewModel.playersInTeam.elementAt(i);
    bool decisionMade = viewModel.decisions[player.id] != null;
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            border: new Border.all(color: color),
            color: decisionMade ? color : null),
        child: new Text(
          player.name,
          style: new TextStyle(fontSize: 16.0, color: decisionMade ? Colors.white : null),
        ));
  });
}

class ActiveHeistViewModel {
  final Set<Player> playersInTeam;
  final Map<String, String> decisions;

  ActiveHeistViewModel._(this.playersInTeam, this.decisions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActiveHeistViewModel &&
              playersInTeam == other.playersInTeam &&
              decisions == other.decisions;

  @override
  int get hashCode =>
      playersInTeam.hashCode ^
      decisions.hashCode;

  @override
  String toString() {
    return 'ActiveHeistViewModel{playersInTeam: $playersInTeam, decisions: $decisions}';
  }
}

Widget makeDecision(BuildContext context, Store<GameModel> store) {
  return new StoreConnector<GameModel, Player>(
      converter: (store) => getSelf(store.state),
      distinct: true,
      builder: (context, me) {
        var choices = [
          const Text('Make your choice', style: infoTextStyle),
          decisionButton(context, store, 'SUCCEED'),
          decisionButton(context, store, 'STEAL'),
        ];
        if (getTeam(me.role) == Team.Agents) {
          choices.add(decisionButton(context, store, 'FAIL'));
        }
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                alignment: Alignment.center,
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: choices)));
      });
}

Widget decisionButton(BuildContext context, Store<GameModel> store, String decision) =>
    new Container(
        child: new RaisedButton(
      onPressed: () => store.dispatch(new MakeDecisionAction(decision)),
      child: new Text(decision, style: buttonTextStyle),
    ));
