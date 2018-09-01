import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/player_info.dart';
import 'package:redux/redux.dart';

class SecretBoard extends StatefulWidget {
  final Store<GameModel> _store;

  SecretBoard(this._store);

  @override
  State<StatefulWidget> createState() {
    return new SecretBoardState(_store);
  }
}

class SecretBoardState extends State<SecretBoard> {
  final Store<GameModel> _store;
  String _kingpinGuess;
  String _accountantSelection;

  SecretBoardState(this._store);

  @override
  Widget build(BuildContext context) => new StoreConnector<GameModel, SecretBoardModel>(
      converter: (store) => new SecretBoardModel._(
          getSelf(store.state),
          getRoom(store.state).visibleToAccountant,
          getRoom(store.state).kingpinGuess,
          getRounds(store.state), // so that the accountant sees updated balances
          requestInProcess(store.state, Request.GuessingKingpin),
          requestInProcess(store.state, Request.SelectingVisibleToAccountant)),
      distinct: true,
      builder: (context, viewModel) {
        List<Widget> children = [
          playerInfo(_store),
          _playerList(),
          _getTeamAndRoleCard(viewModel.me),
        ];

        _addExtraIdsCardIfNeeded(viewModel.me, children);
        _addAccountantCardIfNeeded(viewModel.me, children, viewModel.selectingVisibleToAccountant);
        _addLeadAgentCardIfNeeded(
            viewModel.me, children, viewModel.kingpinGuess, viewModel.guessingKingpin);

        return new Column(children: children);
      });

  Widget _playerList() => new StoreConnector<GameModel, List<Player>>(
        distinct: true,
        converter: (store) => getPlayers(store.state),
        builder: (context, players) {
          if (!gameIsReady(_store.state)) {
            return new Container();
          }
          Player me = getSelf(_store.state);
          Player leader = currentLeader(_store.state);
          List<Widget> children = [
            new Padding(
              padding: paddingTitle,
              child: const Text('Players', style: titleTextStyle),
            ),
          ];
          children.addAll(new List.generate(players.length, (i) {
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
          }));
          return new Card(
            elevation: 2.0,
            child: new Padding(
              padding: paddingMedium,
              child: new Column(children: children),
            ),
          );
        },
      );

  Card _getTeamAndRoleCard(Player me) {
    return new Card(
        elevation: 2.0,
        child: new Padding(
            padding: paddingMedium,
            child: new Row(
              children: [
                new Column(
                  children: [
                    new Text(
                      "You are in team:",
                      style: infoTextStyle,
                    ),
                    new Padding(
                      padding: paddingTitle,
                      child: new Text(
                        "${getTeam(me.role).toString()}",
                        style: titleTextStyle,
                      ),
                    ),
                    new Text(
                      "Your role is:",
                      style: infoTextStyle,
                    ),
                    new Text(
                      "${getRoleDisplayName(me.role)}",
                      style: titleTextStyle,
                    ),
                  ],
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )));
  }

// show the identities the player knows, if any
  _addExtraIdsCardIfNeeded(final Player me, final List<Widget> children) {
    if (getKnownIds(me.role) != null) {
      children.add(new Card(
          elevation: 2.0,
          child: new Padding(
              padding: paddingMedium,
              child: new Column(children: [
                new ListTile(
                  title: new Text(
                    "You also know these identities:",
                    style: infoTextStyle,
                  ),
                  subtitle: new Text(
                    "${_getFormattedKnownIds(getKnownIds(me.role))}",
                    style: infoTextStyle,
                  ),
                ),
              ]))));
    }
  }

  String _getFormattedKnownIds(Set<String> knownIds) {
    String formattedKnownIds = "";
    knownIds?.forEach((roleId) {
      formattedKnownIds += getPlayerByRoleId(_store.state, roleId).name +
          " is the " +
          getRoleDisplayName(roleId) +
          "\n";
    });
    return formattedKnownIds;
  }

// show the balances the accountant knows, if needed
  _addAccountantCardIfNeeded(
      final Player me, final List<Widget> children, final bool selectingVisibleToAccountant) {
    if (me.role == ACCOUNTANT.roleId) {
      final List<Widget> tiles = [];
      // the accountant can reveal a balance per completed heist up to a maximum
      // of half the number of players rounded down
      int completedHeists =
          getHeists(_store.state).where((heist) => heist.completedAt != null).length;
      int numPlayers = getRoom(_store.state).numPlayers;
      int maxBalances = min(completedHeists, (numPlayers / 2).floor());
      tiles.add(
        new ListTile(
          title: new Text(
            'You can also see the balance of up to $maxBalances people:',
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
              '${player.name}: ${calculateBalanceFromStore(_store, player)}',
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
            hint: new Text('PICK BALANCE TO SEE', style: infoTextStyle),
            value: _accountantSelection,
            items: pickablePlayers.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _accountantSelection = newValue;
              });
            }));
        tiles.add(new RaisedButton(
            child: const Text('CONFIRM SELECTION', style: buttonTextStyle),
            onPressed: selectingVisibleToAccountant
                ? null
                : () => _store.dispatch(new AddVisibleToAccountantAction(
                    getPlayerByName(_store.state, _accountantSelection).id))));
      }

      children.add(new Card(
          elevation: 2.0,
          child: new Padding(padding: paddingMedium, child: new Column(children: tiles))));
    }
  }

// show the UI to guess the kingpin, if needed
  _addLeadAgentCardIfNeeded(final Player me, final List<Widget> children, final String kingpinGuess,
      final bool guessingKingpin) {
    if (me.role == LEAD_AGENT.roleId) {
      // the lead agent can try to guess who the kingpin is once during a game
      List<Widget> tiles = [
        new ListTile(
          title: new Text(
            'You can try to guess who the Kingpin is once during the game.'
                ' If you get it right, your bids can be higher than the maximum'
                ' bid from then on.',
            style: infoTextStyle,
          ),
        )
      ];

      if (kingpinGuess == null) {
        List<String> pickablePlayers = getOtherPlayers(_store.state).map((p) => p.name).toList();
        tiles.add(new DropdownButton<String>(
            hint: new Text('SELECT YOUR KINGPIN GUESS', style: infoTextStyle),
            value: _kingpinGuess,
            items: pickablePlayers.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _kingpinGuess = newValue;
              });
            }));
        tiles.add(new RaisedButton(
            child: const Text('CONFIRM GUESS', style: buttonTextStyle),
            onPressed: guessingKingpin
                ? null
                : () => _store.dispatch(
                    new GuessKingpinAction(getPlayerByName(_store.state, _kingpinGuess).id))));
      } else {
        final String kingpinGuessName = getPlayerById(_store.state, kingpinGuess).name;
        final String result = haveGuessedKingpin(_store.state) ? 'CORRECT!' : 'INCORRECT! :(';
        tiles.add(
          new ListTile(
            title: new Text(
              'You checked if $kingpinGuessName is the Kingpin. This is $result',
              style: infoTextStyle,
            ),
          ),
        );
      }

      children.add(new Card(
          elevation: 2.0,
          child: new Padding(padding: paddingMedium, child: new Column(children: tiles))));
    }
  }
}

class SecretBoardModel {
  final Player me;
  final Set<String> visibleToAccountant;
  final String kingpinGuess;
  final Map<String, List<Round>> rounds;
  final bool guessingKingpin;
  final bool selectingVisibleToAccountant;

  SecretBoardModel._(this.me, this.visibleToAccountant, this.kingpinGuess, this.rounds,
      this.guessingKingpin, this.selectingVisibleToAccountant);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretBoardModel &&
          me == other.me &&
          visibleToAccountant == other.visibleToAccountant &&
          kingpinGuess == other.kingpinGuess &&
          rounds == other.rounds &&
          guessingKingpin == other.guessingKingpin &&
          selectingVisibleToAccountant == other.selectingVisibleToAccountant;

  @override
  int get hashCode =>
      me.hashCode ^
      visibleToAccountant.hashCode ^
      kingpinGuess.hashCode ^
      rounds.hashCode ^
      guessingKingpin.hashCode ^
      selectingVisibleToAccountant.hashCode;

  @override
  String toString() {
    return 'SecretBoardModel{player: $me, '
        'visibleToAccountant: $visibleToAccountant, '
        'kingpinGuess: $kingpinGuess, '
        'rounds: $rounds, '
        'guessingKingpin: $guessingKingpin, '
        'selectingVisibleToAccountant: $selectingVisibleToAccountant}';
  }
}
