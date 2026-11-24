class BoncheMemberModel {
  final String id;
  final String name;
  final int xp;
  final int streak;
  final String role;
  final int? completedChallenges;

  const BoncheMemberModel({
    required this.id,
    required this.name,
    required this.xp,
    required this.streak,
    required this.role,
    this.completedChallenges,
  });

  factory BoncheMemberModel.fromJson(Map<String, dynamic> json) {
    return BoncheMemberModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      role: (json['role'] ?? 'MEMBER').toString(),
      completedChallenges: (json['completedChallenges'] as num?)?.toInt(),
    );
  }
}

class BoncheModel {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String leaderId;
  final String? createdAt;
  final List<BoncheMemberModel> members;
  final int challengesPerDay;
  final int windowMinutes;
  final List<String> times;
  final int tzOffset;
  final bool configured;

  const BoncheModel({
    required this.id,
    required this.name,
    required this.description,
    required this.inviteCode,
    required this.leaderId,
    required this.createdAt,
    required this.members,
    required this.challengesPerDay,
    required this.windowMinutes,
    required this.times,
    required this.tzOffset,
    required this.configured,
  });

  int get totalMembers => members.length;

  factory BoncheModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final rawTimes = json['times'];
    return BoncheModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      leaderId: (json['leaderId'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
      members: rawMembers is List
          ? rawMembers
                .map(
                  (m) => BoncheMemberModel.fromJson(m as Map<String, dynamic>),
                )
                .toList()
          : const <BoncheMemberModel>[],
      challengesPerDay: (json['challengesPerDay'] as num?)?.toInt() ?? 3,
      windowMinutes: (json['windowMinutes'] as num?)?.toInt() ?? 90,
      times: rawTimes is List
          ? rawTimes.map((t) => t.toString()).toList()
          : const <String>[],
      tzOffset: (json['tzOffset'] as num?)?.toInt() ?? -300,
      configured: json['configured'] == true,
    );
  }
}
