import '../models/challenge_model.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'challenge_service.dart';

/// Retos del dia del bonche (GET /api/bonches/{id}/challenges/today).
class ApiChallengeService implements ChallengeService {
  const ApiChallengeService();

  static const List<String> _defaultRules = [
    'La foto se toma en el momento, dentro de la app.',
    'Una sola evidencia por reto.',
  ];

  @override
  Future<List<Challenge>> fetchTodayChallenges(String boncheId) async {
    if (boncheId.isEmpty) return const <Challenge>[];
    final items = await ApiService.getBoncheChallenges(boncheId);
    final now = DateTime.now();
    return [for (final item in items) _toChallenge(item, now)];
  }

  Challenge _toChallenge(ChallengeModel m, DateTime now) {
    return Challenge(
      id: m.id,
      title: m.title,
      objective: m.objective,
      description: m.description,
      rules: _defaultRules,
      category: _category(m.category),
      difficulty: _difficulty(m.difficulty),
      evidenceType: _evidenceType(m.evidenceType),
      points: m.points,
      xpReward: m.xpReward,
      coinReward: m.coinReward,
      startsAt: _time(m.startsAt) ?? now.subtract(const Duration(minutes: 15)),
      endsAt: _time(m.endsAt) ?? now.add(const Duration(minutes: 90)),
      completedBy: m.completedBy,
      totalMembers: m.totalMembers,
    );
  }

  static DateTime? _time(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static String _norm(String value) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var out = value.trim().toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  static ChallengeCategory _category(String raw) {
    final key = _norm(raw);
    for (final c in ChallengeCategory.values) {
      if (_norm(c.name) == key || _norm(c.label) == key) return c;
    }
    return ChallengeCategory.observacion;
  }

  static ChallengeDifficulty _difficulty(String raw) {
    final key = _norm(raw);
    for (final d in ChallengeDifficulty.values) {
      if (_norm(d.name) == key || _norm(d.label) == key) return d;
    }
    return ChallengeDifficulty.facil;
  }

  static EvidenceType _evidenceType(String raw) {
    switch (_norm(raw)) {
      case 'voice':
      case 'voz':
        return EvidenceType.voice;
      case 'drawing':
      case 'dibujo':
        return EvidenceType.drawing;
      default:
        return EvidenceType.photo;
    }
  }
}