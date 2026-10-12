import '../utils/formatters.dart';
import 'challenge.dart';

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    required this.level,
    required this.streak,
  });

  final String id;
  final String name;
  final int level;
  final int streak;

  String get initials => initialsFromName(name);

  String get firstName {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Jugador' : parts.first;
  }

  GroupMember copyWith({String? name, int? level, int? streak}) {
    return GroupMember(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
      streak: streak ?? this.streak,
    );
  }
}

class GroupSchedule {
  const GroupSchedule({
    required this.hour,
    required this.minute,
    required this.availableMembers,
  });

  final int hour;
  final int minute;
  final int availableMembers;

  String get label => '${two(hour)}:${two(minute)}';
}

class GroupInfo {
  const GroupInfo({
    required this.name,
    required this.tagline,
    required this.createdAt,
    required this.leaderId,
    required this.inviteCode,
    required this.dailyChallenges,
    required this.windowMinutes,
    required this.schedules,
    required this.categories,
    required this.members,
  });

  final String name;
  final String tagline;
  final DateTime createdAt;
  final String leaderId;
  final String inviteCode;
  final int dailyChallenges;
  final int windowMinutes;
  final List<GroupSchedule> schedules;
  final List<ChallengeCategory> categories;
  final List<GroupMember> members;
}