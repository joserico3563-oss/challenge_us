import '../utils/formatters.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.xp = 0,
    this.coins = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.completedChallenges = 0,
  });

  static const UserProfile empty =
      UserProfile(id: '', displayName: '', email: '');

  final String id;
  final String displayName;
  final String email;
  final int xp;
  final int coins;
  final int streak;
  final int bestStreak;
  final int completedChallenges;

  String get firstName {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Jugador' : parts.first;
  }

  String get initials => initialsFromName(displayName);

  UserProfile copyWith({
    int? xp,
    int? coins,
    int? streak,
    int? bestStreak,
    int? completedChallenges,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName,
      email: email,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedChallenges: completedChallenges ?? this.completedChallenges,
    );
  }
}