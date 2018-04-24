class Room {
  final String id;
  final String code;
  final DateTime createdAt;
  final String appVersion;
  final bool completed;
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles;

  Room(
      {this.id,
      this.code,
      this.createdAt,
      this.appVersion,
      this.completed,
      this.completedAt,
      this.numPlayers,
      this.roles});

  Room.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        createdAt = json['createdAt'],
        appVersion = json['appVersion'],
        completed = json['completed'],
        completedAt = json['completedAt'],
        numPlayers = json['numPlayers'],
        roles = new Set() {
    _decodeRoles(json['roles']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'createdAt': createdAt,
        'appVersion': appVersion,
        'completed': completed,
        'completedAt': completedAt,
        'numPlayers': numPlayers,
        'roles': _encodeRoles(),
      };

  void _decodeRoles(var roleMap) {
    roleMap.forEach((role, b) {
      if (b) {
        roles.add(role);
      }
    });
  }

  Map<String, bool> _encodeRoles() {
    Map<String, bool> encodedRoles = new Map();
    roles.forEach((r) =>
        encodedRoles[r] = true); // TODO: put false for roles not included
    return encodedRoles;
  }
}
