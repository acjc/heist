part of heist;

enum Team {
  Agents, Thieves
}

// agent roles
final Role LEAD_AGENT = new Role(roleId: 'LEAD_AGENT', displayName: 'LEAD AGENT', team: Team.Agents);
final Role AGENT_1 = new Role(roleId: 'AGENT_1', displayName: 'AGENT', team: Team.Agents);
final Role AGENT_2 = new Role(roleId: 'AGENT_2', displayName: 'AGENT', team: Team.Agents);
final Role AGENT_3 = new Role(roleId: 'AGENT_3', displayName: 'AGENT', team: Team.Agents);
// thief roles
final Role KINGPIN = new Role(roleId: 'KINGPIN', displayName: 'KINGPIN', team: Team.Thieves);
final Role ACCOUNTANT = new Role(roleId: 'ACCOUNTANT', displayName: 'ACCOUNTANT', team: Team.Thieves);
final Role THIEF_1 = new Role(roleId: 'THIEF_1', displayName: 'THIEF', team: Team.Thieves);
final Role THIEF_2 = new Role(roleId: 'THIEF_2', displayName: 'THIEF', team: Team.Thieves);
final Role THIEF_3 = new Role(roleId: 'THIEF_3', displayName: 'THIEF', team: Team.Thieves);
final Role THIEF_4 = new Role(roleId: 'THIEF_4', displayName: 'THIEF', team: Team.Thieves);

final Set<Role> allRoles = new Set.of([
  // agents
  LEAD_AGENT, AGENT_1, AGENT_2, AGENT_3,
  // thieves
  KINGPIN, ACCOUNTANT, THIEF_1, THIEF_2, THIEF_3, THIEF_4
]);

final Map<int, Set<Role>> numPlayersToRolesMap = {
  5: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1,
                 LEAD_AGENT, AGENT_1]),
  6: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1, THIEF_2,
                 LEAD_AGENT, AGENT_1]),
  7: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1, THIEF_2,
                 LEAD_AGENT, AGENT_1, AGENT_2]),
  8: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1, THIEF_2, THIEF_3,
                 LEAD_AGENT, AGENT_1, AGENT_2]),
  9: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1, THIEF_2, THIEF_3,
                 LEAD_AGENT, AGENT_1, AGENT_2, AGENT_3]),
  10: new Set.of([ACCOUNTANT, KINGPIN, THIEF_1, THIEF_2, THIEF_3, THIEF_4,
                  LEAD_AGENT, AGENT_1, AGENT_2, AGENT_3]),
};

Set<String> getRolesIds(Set<Role> roles) {
  return roles.map((r) => r.roleId).toSet();
}

@immutable
class Role {
  final String roleId;
  final String displayName;
  final Team team;

  Role({@required this.roleId,
        @required this.displayName,
        @required this.team});
}