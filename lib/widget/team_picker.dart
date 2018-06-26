part of heist;

Widget teamPicker(Store<GameModel> store) {
  return new StoreConnector<GameModel, TeamPickerViewModel>(
      converter: (store) => new TeamPickerViewModel._(currentRound(store.state).id,
          currentHeist(store.state).numPlayers, getPlayers(store.state), teamIds(store.state)),
      distinct: true,
      builder: (context, viewModel) {
        return new Card(
            elevation: 2.0,
            child: new Container(
                padding: paddingMedium,
                child: new Column(children: [
                  new Text(
                      'Pick a team: ${viewModel.teamIds.length} / ${viewModel.playersRequired}',
                      style: infoTextStyle),
                  new GridView.count(
                      padding: paddingMedium,
                      shrinkWrap: true,
                      childAspectRatio: 4.0,
                      crossAxisCount: 2,
                      primary: false,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      children: teamPickerChildren(context, store, viewModel)),
                  new RaisedButton(
                    onPressed: viewModel.teamIds.length == viewModel.playersRequired
                        ? () => store.dispatch(new SubmitTeamAction())
                        : null,
                    child: const Text('SUBMIT TEAM', style: buttonTextStyle),
                  )
                ])));
      });
}

List<Widget> teamPickerChildren(
    BuildContext context, Store<GameModel> store, TeamPickerViewModel viewModel) {
  Color color = Theme.of(context).accentColor;
  return new List.generate(viewModel.players.length, (i) {
    Player player = viewModel.players[i];
    bool isInTeam = viewModel.teamIds.contains(player.id);
    return new GestureDetector(
        onTap: () => onTap(store, viewModel.roundId, player.id, isInTeam),
        child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              border: new Border.all(color: color),
              color: isInTeam ? color : null,
            ),
            child: new Text(
              viewModel.players[i].name,
              style: new TextStyle(
                color: isInTeam ? Colors.white : Colors.black87,
                fontSize: 16.0,
              ),
            )));
  });
}

void onTap(Store<GameModel> store, String roundId, String playerId, bool isInTeam) {
  if (isInTeam) {
    store.dispatch(new RemovePlayerAction(roundId, playerId));
    store.dispatch(new RemovePlayerMiddlewareAction(playerId));
  } else {
    store.dispatch(new PickPlayerAction(roundId, playerId));
    store.dispatch(new PickPlayerMiddlewareAction(playerId));
  }
}

class TeamPickerViewModel {
  final String roundId;
  final int playersRequired;
  final List<Player> players;
  final Set<String> teamIds;

  TeamPickerViewModel._(this.roundId, this.playersRequired, this.players, this.teamIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPickerViewModel &&
          roundId == other.roundId &&
          playersRequired == other.playersRequired &&
          players == other.players &&
          teamIds == other.teamIds;

  @override
  int get hashCode =>
      roundId.hashCode ^ playersRequired.hashCode ^ players.hashCode ^ teamIds.hashCode;

  @override
  String toString() {
    return 'TeamPickerViewModel{roundId: $roundId, playersRequired: $playersRequired, players: $players, teamIds: $teamIds}';
  }
}
