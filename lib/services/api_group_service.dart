import '../models/bonche_model.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'group_service.dart';

/// Bonche real: se crea, se une, se configura y se consulta en la API.
class ApiGroupService implements GroupService {
  const ApiGroupService();

  @override
  Future<GroupInfo?> fetchGroup(String userId) async {
    if (userId.isEmpty) return null;
    final bonches = await ApiService.getUserBonches(userId);
    if (bonches.isEmpty) return null;
    final b = bonches.first;
    return GroupInfo(
      id: b.id,
      configured: b.configured,
      name: b.name,
      tagline: b.description.isEmpty
          ? 'Retos, risas y parche todos los días'
          : b.description,
      createdAt:
          DateTime.tryParse(b.createdAt ?? '')?.toLocal() ?? DateTime.now(),
      leaderId: b.leaderId,
      inviteCode: b.inviteCode,
      dailyChallenges: b.configured ? b.challengesPerDay : 0,
      windowMinutes: b.configured ? b.windowMinutes : 0,
      schedules: b.configured ? _schedules(b) : const <GroupSchedule>[],
      categories: const [],
      members: [
        for (final m in b.members)
          GroupMember(
            id: m.id,
            name: m.name,
            level: LevelSystem.fromXp(m.xp).level,
            streak: m.streak,
            xp: m.xp,
            completedChallenges: m.completedChallenges,
          ),
      ],
    );
  }

  /// Las horas se guardan en la zona del lider; aqui se pasan a la del telefono.
  static List<GroupSchedule> _schedules(BoncheModel b) {
    final deviceOffset = DateTime.now().timeZoneOffset.inMinutes;
    final result = <GroupSchedule>[];
    for (final raw in b.times) {
      final parts = raw.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      var total = h * 60 + m - b.tzOffset + deviceOffset;
      total = ((total % 1440) + 1440) % 1440;
      result.add(
        GroupSchedule(
          hour: total ~/ 60,
          minute: total % 60,
          availableMembers: b.members.length,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> createGroup({
    required String name,
    required String description,
    required String leaderId,
  }) async {
    await ApiService.createBonche(
      name: name,
      description: description,
      leaderId: leaderId,
    );
  }

  @override
  Future<void> joinGroup({
    required String inviteCode,
    required String userId,
  }) async {
    await ApiService.joinBonche(
      inviteCode: inviteCode.trim().toUpperCase(),
      usuarioId: userId,
    );
  }

  @override
  Future<void> updateGroup({
    required String groupId,
    required String userId,
    required String name,
    required int challengesPerDay,
    required int windowMinutes,
    required List<String> times,
    required int tzOffsetMinutes,
  }) async {
    await ApiService.updateBonche(
      boncheId: groupId,
      userId: userId,
      name: name,
      challengesPerDay: challengesPerDay,
      windowMinutes: windowMinutes,
      times: times,
      tzOffset: tzOffsetMinutes,
    );
  }
}
