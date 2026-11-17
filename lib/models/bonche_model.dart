class BoncheMemberModel {
  final String id;
  final String name;
  final int xp;
  final int streak;
  final String role;

  const BoncheMemberModel({
    required this.id,
    required this.name,
    required this.xp,
    required this.streak,
    required this.role,
  });

  factory BoncheMemberModel.fromJson(Map<String, dynamic> json) {
    return BoncheMemberModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      role: (json['role'] ?? 'MEMBER').toString(),
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

  const BoncheModel({
    required this.id,
    required this.name,
    required this.description,
    required this.inviteCode,
    required this.leaderId,
    required this.createdAt,
    required this.members,
  });

  int get totalMembers => members.length;

  factory BoncheModel.fromJson(Map<String, dynamic> json) {
    final raw = json['members'];
    return BoncheModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      leaderId: (json['leaderId'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
      members: raw is List
          ? raw
              .map((m) => BoncheMemberModel.fromJson(m as Map<String, dynamic>))
              .toList()
          : const <BoncheMemberModel>[],
    );
  }
}