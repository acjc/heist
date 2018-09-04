import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heist/app_localizations.dart';

class Team {
  final _value;
  const Team._internal(this._value);
  toString() => '$_value';

  static const AGENTS = const Team._internal('AGENTS');
  static const THIEVES = const Team._internal('THIEVES');
}

// agent roles
final Role LEAD_AGENT = new Role(
    roleId: 'LEAD_AGENT',
    displayNameFunc: (BuildContext context) => AppLocalizations.of(context).leadAgent,
    team: Team.AGENTS);
final Role AGENT_1 = new Agent(roleId: 'AGENT_1');
final Role AGENT_2 = new Agent(roleId: 'AGENT_2');
final Role AGENT_3 = new Agent(roleId: 'AGENT_3');
// thief roles
final Role KINGPIN = new Role(
    roleId: 'KINGPIN',
    displayNameFunc: (BuildContext context) => AppLocalizations.of(context).kingpin,
    team: Team.THIEVES,
    knownIds: new Set.of(['LEAD_AGENT']));
final Role ACCOUNTANT = new Role(
    roleId: 'ACCOUNTANT',
    displayNameFunc: (BuildContext context) => AppLocalizations.of(context).accountant,
    team: Team.THIEVES);
final Role THIEF_1 = new Thief(roleId: 'THIEF_1');
final Role THIEF_2 = new Thief(roleId: 'THIEF_2');
final Role THIEF_3 = new Thief(roleId: 'THIEF_3');
final Role THIEF_4 = new Thief(roleId: 'THIEF_4');

final Set<Role> allRoles = new Set.of([
  // agents
  LEAD_AGENT, AGENT_1, AGENT_2, AGENT_3,
  // thieves
  KINGPIN, ACCOUNTANT, THIEF_1, THIEF_2, THIEF_3, THIEF_4
]);

final Map<int, Set<Role>> numPlayersToRolesMap = {
  2: new Set.of([
    KINGPIN,
    LEAD_AGENT,
  ]),
  3: new Set.of([
    KINGPIN,
    ACCOUNTANT,
    LEAD_AGENT,
  ]),
  4: new Set.of([
    KINGPIN,
    ACCOUNTANT,
    LEAD_AGENT,
    AGENT_1,
  ]),
  5: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    LEAD_AGENT,
    AGENT_1,
  ]),
  6: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    THIEF_2,
    LEAD_AGENT,
    AGENT_1,
  ]),
  7: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    THIEF_2,
    LEAD_AGENT,
    AGENT_1,
    AGENT_2,
  ]),
  8: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    THIEF_2,
    THIEF_3,
    LEAD_AGENT,
    AGENT_1,
    AGENT_2,
  ]),
  9: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    THIEF_2,
    THIEF_3,
    LEAD_AGENT,
    AGENT_1,
    AGENT_2,
    AGENT_3,
  ]),
  10: new Set.of([
    ACCOUNTANT,
    KINGPIN,
    THIEF_1,
    THIEF_2,
    THIEF_3,
    THIEF_4,
    LEAD_AGENT,
    AGENT_1,
    AGENT_2,
    AGENT_3,
  ]),
};

final getRoleIds = (Set<Role> roles) => roles.map((r) => r.roleId).toSet();

final getTeam = (String roleId) => allRoles.singleWhere((r) => r.roleId == roleId).team;

final getKnownIds = (String roleId) => allRoles.singleWhere((r) => r.roleId == roleId).knownIds;

final getRoleDisplayName = (BuildContext context, String roleId)
    => allRoles.singleWhere((r) => r.roleId == roleId).displayNameFunc(context);

@immutable
class Role {
  final String roleId;
  final String Function(BuildContext) displayNameFunc;
  final Team team;
  final Set<String> knownIds;

  Role({@required this.roleId, @required this.displayNameFunc, @required this.team, this.knownIds});
}

@immutable
class Agent extends Role {
  Agent({roleId})
      : super(
          roleId: roleId,
          displayNameFunc: (BuildContext context) => AppLocalizations.of(context).agent,
          team: Team.AGENTS,
          knownIds: new Set.of(['LEAD_AGENT']),
        );
}

@immutable
class Thief extends Role {
  Thief({roleId}) : super(
      roleId: roleId,
      displayNameFunc: (BuildContext context) => AppLocalizations.of(context).thief,
      team: Team.THIEVES);
}
