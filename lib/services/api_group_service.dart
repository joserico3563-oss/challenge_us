import '../models/models.dart';
import 'api_service.dart';
import 'group_service.dart';

/// Bonche real: se crea, se une y se consulta en la API de Render.
class ApiGroupService implements GroupService {
  const ApiGroupService();

  @override
  Future<GroupInfo?> fetchGroup(String userId) async {
    if (userId.isEmpty) return null;
    final bonches = await ApiService.getUserBonches(userId);
    if (bonches.isEmpty) return null;
    final b = bonches.first;
    return GroupInfo(
      name: b.name,
      tagline: b.description.isEmpty
          ? 'Retos, risas y parche todos los días'
          : b.description,
      createdAt:
          DateTime.tryParse(b.createdAt ?? '')?.toLocal() ?? DateTime.now(),
      leaderId: b.leaderId,
      inviteCode: b.inviteCode,
      dailyChallenges: 0,
      windowMinutes: 0,
      schedules: const [],
      categories: const [],
      members: [
        for (final m in b.members)
          GroupMember(
            id: m.id,
            name: m.name,
            level: LevelSystem.fromXp(m.xp).level,
            streak: m.streak,
          ),
      ],
    );
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
}