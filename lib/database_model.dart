
class Room {

  final String id;
  final String code;
  final DateTime createdAt;
  final String appVersion;
  final bool completed;
  final DateTime completedAt;
  final int numPlayers;
  final Set<String> roles = new Set();

  Room.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        createdAt = json['createdAt'],
        appVersion = json['appVersion'],
        completed = json['completed'],
        completedAt = json['completedAt'],
        numPlayers = json['numPlayers'] {
    _parseRoles(json['roles']);
  }

  void _parseRoles(var roles) {
    roles.forEach((role, b) {
      if (b) {
        this.roles.add(role);
      }
    });
  }
}
