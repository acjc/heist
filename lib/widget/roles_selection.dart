import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:heist/app_localizations.dart';
import 'package:heist/colors.dart';
import 'package:heist/middleware/room_middleware.dart';
import 'package:heist/role.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:redux/redux.dart';

class RolesSelection extends StatefulWidget {
  final Store<GameModel> _store;

  RolesSelection(this._store);

  @override
  State<StatefulWidget> createState() => _RolesSelectionState(_store);
}

class _RolesSelectionState extends State<RolesSelection> {
  final Store<GameModel> _store;

  _RolesSelectionState(this._store);

  @override
  Widget build(BuildContext context) => StoreConnector<GameModel, RolesSelectionModel>(
      converter: (store) => RolesSelectionModel._(
          getRoom(store.state).numPlayers, amOwner(store.state), getRoom(store.state).roles),
      distinct: true,
      builder: (context, viewModel) {
        if (getPlayers(_store.state).isNotEmpty) {
          return choosingRoles(viewModel.numPlayers, viewModel.amOwner, viewModel.roleIds);
        } else {
          return loading();
        }
      });

  Widget choosingRoles(final int numPlayers, final bool amOwner, final Set<String> currentRoleIds) {
    final Set<Role> defaultRoles = Roles.numPlayersToRolesMap[numPlayers];
    final int numFriendlyRoles = getNumRolesInTeam(Roles.getRoleIds(defaultRoles), Team.FRIENDLY);
    final int numScaryRoles = getNumRolesInTeam(Roles.getRoleIds(defaultRoles), Team.SCARY);

    final List<Widget> friendlyRolesList =
        getRolesList(Team.FRIENDLY, HeistColors.peach, currentRoleIds, numFriendlyRoles, amOwner);
    final List<Widget> scaryRolesList =
        getRolesList(Team.SCARY, HeistColors.purple, currentRoleIds, numScaryRoles, amOwner);

    final List<Widget> children = [
      Padding(
          padding: paddingMedium,
          child: centeredTitle(amOwner
              ? AppLocalizations.of(context).chooseGameRoles(getRoom(_store.state).code)
              : AppLocalizations.of(context).someoneElseChoosesGameRoles(
                  getRoom(_store.state).code, getOwnerName(_store.state)))),
      Padding(
          padding: paddingSmall,
          child: Text(
            AppLocalizations.of(context).friendlyTeam(numFriendlyRoles),
            style: titleTextStyle,
          )),
      MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2, // 2 columns
            childAspectRatio: 3.0,
            children: friendlyRolesList,
          )),
      Padding(
          padding: paddingSmall,
          child: Text(
            AppLocalizations.of(context).scaryTeam(numScaryRoles),
            style: titleTextStyle,
          )),
      MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2, // 2 columns
            childAspectRatio: 3.0,
            children: scaryRolesList,
          )),
    ];

    if (amOwner) {
      children.add(RaisedButton(
        child: Text(
          AppLocalizations.of(context).submit,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: (getNumRolesInTeam(currentRoleIds, Team.FRIENDLY) == numFriendlyRoles &&
                getNumRolesInTeam(currentRoleIds, Team.SCARY) == numScaryRoles)
            ? () => _store.dispatch(SubmitRolesAction())
            : null,
      ));
    }

    return Center(
        child: Card(
      elevation: 2.0,
      margin: paddingMedium,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    ));
  }

  int getNumRolesInTeam(final Set<String> roleIds, final Team team) {
    return roleIds.where((roleId) => Roles.getTeam(roleId) == team).toList().length;
  }

  List<Widget> getRolesList(final Team team, final Color color, final Set<String> selectedRoleIds,
      final int numRolesInTeam, final bool amOwner) {
    final List<Role> teamRoles =
        Roles.allRoles.where((role) => Roles.getTeam(role.roleId) == team).toList();
    final List<Widget> rolesList = [];
    rolesList.addAll(List.generate(teamRoles.length, (i) {
      final Role role = teamRoles.elementAt(i);
      final String roleId = role.roleId;
      final bool compulsory = role.compulsory;
      final Text text = Text(Roles.getRoleDisplayName(context, roleId),
          style: Theme.of(context).textTheme.button, textAlign: TextAlign.center);
      final Widget content =
          compulsory ? iconText(Icon(Icons.star, color: Colors.white), text) : text;
      return Padding(
          padding: paddingNano,
          child: RaisedButton(
              color: selectedRoleIds.contains(roleId) ? color : Colors.grey,
              child: content,
              onPressed: () => amOwner
                  ? selectedRoleIds.contains(roleId)
                      ? compulsory
                          ? showCantDoActionDialog(AppLocalizations.of(context).compulsoryRoles(
                              Roles.getRoleDisplayName(context, Roles.bertie.roleId),
                              Roles.getRoleDisplayName(context, Roles.brenda.roleId)))
                          : _store.dispatch(RemoveRoleAction(roleId))
                      : getNumRolesInTeam(selectedRoleIds, team) == numRolesInTeam
                          ? showCantDoActionDialog(AppLocalizations.of(context).fullTeam)
                          : _store.dispatch(AddRoleAction(roleId))
                  : showCantDoActionDialog(AppLocalizations.of(context).onlyOwnerModifies)));
    }));
    return rolesList;
  }

  showCantDoActionDialog(final String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context).notAllowed),
                content: Text(content),
                actions: <Widget>[
                  FlatButton(
                    child: Text(AppLocalizations.of(context).okButton),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]));
  }
}

class RolesSelectionModel {
  final int numPlayers;
  final bool amOwner;
  final Set<String> roleIds;

  RolesSelectionModel._(this.numPlayers, this.amOwner, this.roleIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RolesSelectionModel &&
          numPlayers == other.numPlayers &&
          amOwner == other.amOwner &&
          roleIds == other.roleIds;

  @override
  int get hashCode => numPlayers.hashCode ^ amOwner.hashCode ^ roleIds.hashCode;

  @override
  String toString() {
    return 'RolesSelectionModel{'
        ' numPlayers: $numPlayers,'
        ' amOwner: $amOwner,'
        ' roleIds: $roleIds}';
  }
}
