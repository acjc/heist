import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';

class Team {
  final _value;
  const Team._internal(this._value);
  toString() => '$_value';

  static const FRIENDLY = const Team._internal('FRIENDLY');
  static const SCARY = const Team._internal('SCARY');
}

class Roles {
  // friendly roles
  static final Role bertie = new Role(
      roleId: 'BERTIE',
      displayNameFunc: (BuildContext context) => AppLocalizations.of(context).bertie,
      team: Team.FRIENDLY);

  static final Role friendlyGhost1 = new FriendlyGhost(roleId: 'FRIENDLY_GHOST_1');
  static final Role friendlyGhost2 = new FriendlyGhost(roleId: 'FRIENDLY_GHOST_2');
  static final Role friendlyGhost3 = new FriendlyGhost(roleId: 'FRIENDLY_GHOST_3');

  // scary roles
  static final Role brenda = new Role(
      roleId: 'BRENDA',
      displayNameFunc: (BuildContext context) => AppLocalizations.of(context).brenda,
      team: Team.SCARY,
      knownIds: new Set.of(['BERTIE']));
  static final Role accountant = new Role(
      roleId: 'ACCOUNTANT',
      displayNameFunc: (BuildContext context) => AppLocalizations.of(context).formerAccountantGhost,
      team: Team.SCARY);
  static final Role scaryGhost1 = new ScaryGhost(roleId: 'SCARY_GHOST_1');
  static final Role scaryGhost2 = new ScaryGhost(roleId: 'SCARY_GHOST_2');
  static final Role scaryGhost3 = new ScaryGhost(roleId: 'SCARY_GHOST_3');
  static final Role scaryGhost4 = new ScaryGhost(roleId: 'SCARY_GHOST_4');

  static final Set<Role> allRoles = new Set.of([
    // friendly
    bertie, friendlyGhost1, friendlyGhost2, friendlyGhost3,
    // scary
    brenda, accountant, scaryGhost1, scaryGhost2, scaryGhost3, scaryGhost4
  ]);

  static final Map<int, Set<Role>> numPlayersToRolesMap = {
    2: new Set.of([
      brenda,
      bertie,
    ]),
    3: new Set.of([
      brenda,
      accountant,
      bertie,
    ]),
    4: new Set.of([
      brenda,
      accountant,
      bertie,
      friendlyGhost1,
    ]),
    5: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      bertie,
      friendlyGhost1,
    ]),
    6: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      scaryGhost2,
      bertie,
      friendlyGhost1,
    ]),
    7: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      scaryGhost2,
      bertie,
      friendlyGhost1,
      friendlyGhost2,
    ]),
    8: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      scaryGhost2,
      scaryGhost3,
      bertie,
      friendlyGhost1,
      friendlyGhost2,
    ]),
    9: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      scaryGhost2,
      scaryGhost3,
      bertie,
      friendlyGhost1,
      friendlyGhost2,
      friendlyGhost3,
    ]),
    10: new Set.of([
      brenda,
      accountant,
      scaryGhost1,
      scaryGhost2,
      scaryGhost3,
      scaryGhost4,
      bertie,
      friendlyGhost1,
      friendlyGhost2,
      friendlyGhost3,
    ]),
  };

  static final getRoleIds = (Set<Role> roles) => roles.map((r) => r.roleId).toSet();

  static final getTeam = (String roleId) => allRoles.singleWhere((r) => r.roleId == roleId).team;

  static final getKnownIds =
      (String roleId) => allRoles.singleWhere((r) => r.roleId == roleId).knownIds;

  static final getRoleDisplayName = (BuildContext context, String roleId) =>
      allRoles.singleWhere((r) => r.roleId == roleId).displayNameFunc(context);
}

@immutable
class Role {
  final String roleId;
  final String Function(BuildContext) displayNameFunc;
  final Team team;
  final Set<String> knownIds;

  Role({@required this.roleId, @required this.displayNameFunc, @required this.team, this.knownIds});
}

@immutable
class FriendlyGhost extends Role {
  FriendlyGhost({roleId})
      : super(
          roleId: roleId,
          displayNameFunc: (BuildContext context) => AppLocalizations.of(context).friendlyGhost,
          team: Team.FRIENDLY,
          knownIds: new Set.of(['BERTIE']),
        );
}

@immutable
class ScaryGhost extends Role {
  ScaryGhost({roleId})
      : super(
            roleId: roleId,
            displayNameFunc: (BuildContext context) => AppLocalizations.of(context).scaryGhost,
            team: Team.SCARY);
}
