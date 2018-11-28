import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/reducers/local_actions_reducers.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/player_info.dart';
import 'package:redux/redux.dart';

class SecretBoard extends StatefulWidget {
  final Store<GameModel> _store;
  final Widget _footer;

  SecretBoard(this._store, this._footer);

  @override
  State<StatefulWidget> createState() => SecretBoardState(_store);
}

class SecretBoardState extends State<SecretBoard> {
  final Store<GameModel> _store;
  String _brendaGuess;
  String _accountantSelection;

  SecretBoardState(this._store);

  @override
  Widget build(BuildContext context) => new StoreConnector<GameModel, SecretBoardModel>(
      converter: (store) => new SecretBoardModel._(
          getSelf(store.state),
          getRoom(store.state).visibleToAccountant,
          getRoom(store.state).brendaGuess,
          getRounds(store.state), // so that the accountant sees updated balances
          requestInProcess(store.state, Request.GuessingBrenda),
          requestInProcess(store.state, Request.SelectingVisibleToAccountant)),
      distinct: true,
      builder: (context, viewModel) {
        List<Widget> children = [
          description(),
          playerInfo(_store),
          _getSecretInfoCard(viewModel.me),
        ];

        _addAccountantCardIfNeeded(viewModel.me, children, viewModel.selectingVisibleToAccountant);
        _addBertieCardIfNeeded(
            viewModel.me, children, viewModel.brendaGuess, viewModel.guessingBrenda);

        children.add(_playerList());

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: paddingMedium,
                child: ListView(
                  children: children,
                ),
              ),
            ),
            widget._footer,
          ],
        );
      });

  Widget description() => HeaderCard(
        title: AppLocalizations.of(context).secretHeader,
        child: Text(
          AppLocalizations.of(context).secretHeaderDescription,
          textAlign: TextAlign.center,
          style: descriptionTextStyle,
        ),
        expanded:
            !generalLocalActionRecorded(_store.state, GeneralLocalAction.SecretDescriptionClosed),
        onExpansionChanged: (open) {
          if (!open) {
            _store.dispatch(
              RecordGeneralLocalActionAction(GeneralLocalAction.SecretDescriptionClosed),
            );
          }
        },
      );

  Widget _playerList() => new StoreConnector<GameModel, List<Player>>(
        distinct: true,
        converter: (store) => getPlayers(store.state),
        builder: (context, players) {
          if (!gameIsReady(_store.state)) {
            return new Container();
          }
          Player me = getSelf(_store.state);
          Player leader = currentLeader(_store.state);
          List<Widget> children = new List.generate(players.length, (i) {
            Player player = players[i];
            TextStyle textStyle = player.id == me.id ? boldTextStyle : infoTextStyle;
            if (player.id == leader.id) {
              return new Padding(
                padding: paddingBelowText,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Text('${player.order}. ', style: textStyle),
                    iconText(
                      new Icon(Icons.star_border, size: 20.0),
                      new Text(player.name, style: textStyle),
                      trailingIcon: true,
                    ),
                  ],
                ),
              );
            }
            return new Padding(
              padding: paddingBelowText,
              child: new Text('${player.order}. ${player.name}', style: textStyle),
            );
          });
          return new TitledCard(
            title: AppLocalizations.of(context).playerList,
            child: new Padding(
              padding: paddingMedium,
              child: new Column(children: children),
            ),
          );
        },
      );

  Widget _getSecretInfoCard(Player me) {
    List<Widget> children = [
      Text(AppLocalizations.of(context).team),
      Padding(
        padding: paddingTitle,
        child: Text(
          "${Roles.getTeam(me.role).toString()}",
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
      Text(AppLocalizations.of(context).role),
      Text(
        "${Roles.getRoleDisplayName(context, me.role).toUpperCase()}",
        style: Theme.of(context).textTheme.subhead,
      ),
    ];

    if (Roles.getKnownIds(me.role) != null) {
      children.add(Padding(
          padding: paddingMedium,
          child: ListTile(
            title: Text(AppLocalizations.of(context).otherIdentities),
            subtitle: Text(
              "${_getFormattedKnownIds(Roles.getKnownIds(me.role))}",
              style: Theme.of(context).textTheme.subhead,
            ),
          )));
    }

    return TitledCard(
      title: AppLocalizations.of(context).roleInfo,
      child: Padding(
        padding: paddingMedium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedKnownIds(Set<String> knownIds) {
    String formattedKnownIds = "";
    knownIds?.forEach((roleId) {
      formattedKnownIds += AppLocalizations.of(context).identity(
          getPlayerByRoleId(_store.state, roleId).name, Roles.getRoleDisplayName(context, roleId));
    });
    return formattedKnownIds;
  }

  /// Show the balances the accountant knows, if needed
  _addAccountantCardIfNeeded(Player me, List<Widget> children, bool selectingVisibleToAccountant) {
    if (me.role == Roles.accountant.roleId) {
      final List<Widget> tiles = [];
      // the accountant can reveal a balance per completed haunt up to a maximum
      // of half the number of players rounded down
      int completedHaunts =
          getHaunts(_store.state).where((haunt) => haunt.completedAt != null).length;
      int numPlayers = getRoom(_store.state).numPlayers;
      int maxBalances = min(completedHaunts, (numPlayers / 2).floor());
      tiles.add(
        new ListTile(
          title: new Text(
            AppLocalizations.of(context).accountantExplanation(maxBalances),
            style: infoTextStyle,
          ),
        ),
      );

      Set<String> visibleToAccountant = getRoom(_store.state).visibleToAccountant;

      visibleToAccountant?.forEach((String playerId) {
        Player player = getPlayerById(_store.state, playerId);
        tiles.add(
          new ListTile(
            title: new Text(
              '${player.name}: ${calculateBalanceFromState(_store.state, player)}',
              style: infoTextStyle,
            ),
          ),
        );
      });

      if (maxBalances > 0 && maxBalances > visibleToAccountant?.length) {
        List<String> pickablePlayers = getOtherPlayers(_store.state)
            .where((p) => !visibleToAccountant.contains(p.id))
            .map((p) => p.name)
            .toList();
        tiles.add(new DropdownButton<String>(
            hint: new Text(AppLocalizations.of(context).accountantPickPlayer, style: infoTextStyle),
            value: _accountantSelection,
            items: pickablePlayers.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value, style: lightTheme.textTheme.subhead),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _accountantSelection = newValue;
              });
            }));
        tiles.add(new RaisedButton(
            child: new Text(
              AppLocalizations.of(context).accountantConfirmPlayer,
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: selectingVisibleToAccountant
                ? null
                : () => _store.dispatch(new AddVisibleToAccountantAction(
                    getPlayerByName(_store.state, _accountantSelection).id))));
      }

      children.add(
        new TitledCard(
          title: AppLocalizations.of(context).secretActions,
          child: new Padding(
            padding: paddingMedium,
            child: new Column(children: tiles),
          ),
        ),
      );
    }
  }

  /// Show the UI to guess Brenda, if needed
  _addBertieCardIfNeeded(
    Player me,
    List<Widget> children,
    String brendaGuess,
    bool guessingBrenda,
  ) {
    if (me.role == Roles.bertie.roleId) {
      // the lead agent can try to guess who Brenda is once during a game
      List<Widget> tiles = [
        Padding(
          padding: paddingTiny,
          child: Text(
            AppLocalizations.of(context).bertieExplanation,
            textAlign: TextAlign.center,
          ),
        ),
      ];

      if (brendaGuess == null) {
        List<String> pickablePlayers = getOtherPlayers(_store.state).map((p) => p.name).toList();
        tiles.add(new DropdownButton<String>(
            hint: Padding(
              padding: paddingTiny,
              child: Text(AppLocalizations.of(context).bertiePickPlayer),
            ),
            value: _brendaGuess,
            items: pickablePlayers.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _brendaGuess = newValue;
              });
            }));
        tiles.add(new RaisedButton(
            child: new Text(
              AppLocalizations.of(context).bertieConfirmPlayer,
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: guessingBrenda
                ? null
                : () => _store.dispatch(
                    new GuessBrendaAction(getPlayerByName(_store.state, _brendaGuess).id))));
      } else {
        final String brendaGuessName = getPlayerById(_store.state, brendaGuess).name;
        final String result = haveGuessedBrenda(_store.state)
            ? AppLocalizations.of(context).bertieResultRight
            : AppLocalizations.of(context).bertieResultWrong;
        tiles.add(Padding(
          padding: paddingTiny,
          child: new Text(
            AppLocalizations.of(context).bertieResult(brendaGuessName, result),
            textAlign: TextAlign.center,
          ),
        ));
      }

      children.add(
        new TitledCard(
          title: AppLocalizations.of(context).secretActions,
          child: new Padding(
            padding: paddingMedium,
            child: new Column(children: tiles),
          ),
        ),
      );
    }
  }
}

class SecretBoardModel {
  final Player me;
  final Set<String> visibleToAccountant;
  final String brendaGuess;
  final Map<String, List<Round>> rounds;
  final bool guessingBrenda;
  final bool selectingVisibleToAccountant;

  SecretBoardModel._(this.me, this.visibleToAccountant, this.brendaGuess, this.rounds,
      this.guessingBrenda, this.selectingVisibleToAccountant);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretBoardModel &&
          me == other.me &&
          visibleToAccountant == other.visibleToAccountant &&
          brendaGuess == other.brendaGuess &&
          rounds == other.rounds &&
          guessingBrenda == other.guessingBrenda &&
          selectingVisibleToAccountant == other.selectingVisibleToAccountant;

  @override
  int get hashCode =>
      me.hashCode ^
      visibleToAccountant.hashCode ^
      brendaGuess.hashCode ^
      rounds.hashCode ^
      guessingBrenda.hashCode ^
      selectingVisibleToAccountant.hashCode;

  @override
  String toString() {
    return 'SecretBoardModel{player: $me, '
        'visibleToAccountant: $visibleToAccountant, '
        'brendaGuess: $brendaGuess, '
        'rounds: $rounds, '
        'guessingBrenda: $guessingBrenda, '
        'selectingVisibleToAccountant: $selectingVisibleToAccountant}';
  }
}
