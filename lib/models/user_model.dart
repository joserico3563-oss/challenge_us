class UserModel {
  final String id;
  final String displayName;
  final String email;
  final int xp;
  final int coins;
  final int streak;
  final int bestStreak;
  final int completedChallenges;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.bestStreak,
    required this.completedChallenges,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      xp: json['xp'] ?? 0,
      coins: json['coins'] ?? 0,
      streak: json['streak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      completedChallenges: json['completedChallenges'] ?? 0,
    );
  }
}