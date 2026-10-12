import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/formatters.dart';

/// Datos locales de ejemplo. Los horarios se calculan respecto a "ahora" para
/// que siempre haya un reto activo al probar la app.
class MockData {
  MockData._();

  static const int groupSize = 5;

  // --- Usuario ---------------------------------------------------------------

  static UserProfile userFor({required String email, String? displayName}) {
    return UserProfile(
      id: 'u-001',
      displayName: displayName ?? _nameFromEmail(email),
      email: email,
      xp: 85,
      coins: 120,
      streak: 4,
      bestStreak: 7,
      completedChallenges: 12,
    );
  }

  static String _nameFromEmail(String email) {
    final local =
        email.split('@').first.replaceAll(RegExp(r'[._\-]+'), ' ').trim();
    if (local.isEmpty) return 'Jugador';
    return local
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  // --- Retos -----------------------------------------------------------------

  static List<Challenge> todayChallenges(DateTime now) {
    return [
      Challenge(
        id: 'ch-001',
        title: 'Dame un color',
        objective: 'Fotografía algo de color amarillo que tengas cerca.',
        description:
            'Busca a tu alrededor un objeto amarillo y tómale una foto clara. '
            'Vale cualquier cosa: una fruta, una prenda, un cuaderno... lo '
            'importante es que el color se note.',
        rules: const [
          'La foto se toma en el momento, dentro de la app.',
          'El objeto amarillo debe ocupar buena parte del encuadre.',
          'No vale fotografiar otra pantalla ni otra foto.',
          'Una sola evidencia por reto.',
        ],
        category: ChallengeCategory.observacion,
        difficulty: ChallengeDifficulty.facil,
        evidenceType: EvidenceType.photo,
        points: 100,
        xpReward: 40,
        coinReward: 25,
        startsAt: now.subtract(const Duration(minutes: 15)),
        endsAt: now.add(const Duration(hours: 1, minutes: 45)),
        completedBy: 3,
        totalMembers: groupSize,
      ),
      Challenge(
        id: 'ch-002',
        title: 'Arte con lo que hay',
        objective: 'Arma una mini escena creativa con tres objetos.',
        description:
            'Junta tres objetos que tengas a la mano y organízalos como si '
            'fueran una pequeña obra de arte. Gana la composición más original.',
        rules: const [
          'Usa exactamente tres objetos.',
          'La foto debe tomarse dentro de la app.',
          'Se vale ser gracioso, pero que se entienda la idea.',
        ],
        category: ChallengeCategory.creatividad,
        difficulty: ChallengeDifficulty.medio,
        evidenceType: EvidenceType.photo,
        points: 150,
        xpReward: 60,
        coinReward: 40,
        startsAt: now.add(const Duration(hours: 3)),
        endsAt: now.add(const Duration(hours: 4, minutes: 30)),
        completedBy: 0,
        totalMembers: groupSize,
      ),
      Challenge(
        id: 'ch-003',
        title: 'Mano amiga',
        objective:
            'Foto de tu mano sosteniendo el objeto más raro que encuentres.',
        description:
            'Se trata de ingenio: busca el objeto más inesperado de tu casa y '
            'muéstralo sostenido en tu mano.',
        rules: const [
          'En la foto debe verse tu mano y el objeto.',
          'Foto tomada dentro de la app.',
        ],
        category: ChallengeCategory.ingenio,
        difficulty: ChallengeDifficulty.dificil,
        evidenceType: EvidenceType.photo,
        points: 200,
        xpReward: 80,
        coinReward: 55,
        startsAt: now.subtract(const Duration(hours: 6)),
        endsAt: now.subtract(const Duration(hours: 4)),
        completedBy: 4,
        totalMembers: groupSize,
      ),
    ];
  }

  // --- Bonche ----------------------------------------------------------------

  static GroupInfo group(DateTime now) {
    return GroupInfo(
      name: 'Los de la Terraza',
      tagline: 'Retos, risas y parche todos los días',
      createdAt: DateTime(now.year, now.month - 2, 12),
      leaderId: 'u-002',
      inviteCode: 'TERRAZA-48K2',
      dailyChallenges: 3,
      windowMinutes: 90,
      schedules: const [
        GroupSchedule(hour: 10, minute: 0, availableMembers: 5),
        GroupSchedule(hour: 15, minute: 30, availableMembers: 4),
        GroupSchedule(hour: 20, minute: 0, availableMembers: 5),
      ],
      categories: const [
        ChallengeCategory.observacion,
        ChallengeCategory.creatividad,
        ChallengeCategory.movimiento,
        ChallengeCategory.ingenio,
      ],
      members: const [
        GroupMember(id: 'u-001', name: 'Daniel Escudero', level: 1, streak: 4),
        GroupMember(id: 'u-002', name: 'Mateo Ríos', level: 6, streak: 12),
        GroupMember(id: 'u-003', name: 'Miguel Rodríguez', level: 5, streak: 8),
        GroupMember(id: 'u-004', name: 'Levis Ortiz', level: 4, streak: 3),
        GroupMember(id: 'u-005', name: 'José Rico', level: 3, streak: 5),
      ],
    );
  }

  static List<ChatMessage> chatMessages(DateTime now) {
    return [
      ChatMessage(
        id: 'm-1',
        authorId: 'u-002',
        text: 'Buenas, bonche. Hoy hay reto de colores, a ver quién lo saca primero.',
        sentAt: now.subtract(const Duration(minutes: 95)),
      ),
      ChatMessage(
        id: 'm-2',
        authorId: 'u-003',
        text: 'Yo ya vi algo amarillo en la cocina. Ahorita lo hago.',
        sentAt: now.subtract(const Duration(minutes: 80)),
      ),
      ChatMessage.system(
        id: 'm-3',
        text: 'Camila completó "Dame un color"',
        sentAt: now.subtract(const Duration(minutes: 62)),
      ),
      ChatMessage(
        id: 'm-4',
        authorId: 'u-004',
        text: 'Esa va a estar peleada, Mateo.',
        sentAt: now.subtract(const Duration(minutes: 40)),
      ),
      ChatMessage(
        id: 'm-5',
        authorId: 'u-005',
        text: 'Se me acabó el amarillo, tocó improvisar.',
        sentAt: now.subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  // --- Ranking ---------------------------------------------------------------

  static RankingBoard rankingBoard(RankingPeriod period, DateTime now) {
    return period == RankingPeriod.weekly ? _weeklyBoard(now) : _monthlyBoard(now);
  }

  /// Serie acumulada hasta [lastIndex], escalada para que el último valor
  /// coincida con [total].
  static List<double> _cumulative(
    List<double> weights,
    int lastIndex,
    double total,
  ) {
    final slice = weights.sublist(0, lastIndex + 1);
    var sum = 0.0;
    for (final weight in slice) {
      sum += weight;
    }
    final result = <double>[];
    var running = 0.0;
    for (final weight in slice) {
      running += weight;
      result.add(sum == 0 ? 0 : running / sum * total);
    }
    return result;
  }

  static RankingBoard _weeklyBoard(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final monday =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);
    final daysLeft = nextMonday.difference(today).inDays;
    final todayIndex = today.weekday - 1;

    const entries = [
      RankingEntry(memberId: 'u-002', points: 460, completed: 9, wins: 3, previousRank: 1),
      RankingEntry(memberId: 'u-003', points: 390, completed: 8, wins: 2, previousRank: 2),
      RankingEntry(memberId: 'u-001', points: 310, completed: 6, wins: 1, previousRank: 3),
      RankingEntry(memberId: 'u-004', points: 280, completed: 5, wins: 1, previousRank: 4),
      RankingEntry(memberId: 'u-005', points: 190, completed: 4, wins: 0, previousRank: 5),
    ];

    final userBase =
        entries.firstWhere((e) => e.memberId == 'u-001').points.toDouble();
    final groupAverage =
        entries.fold<int>(0, (sum, e) => sum + e.points) / entries.length;

    const winners = ['u-002', 'u-003', 'u-001', 'u-002'];
    const ranks = [3, 2, 1, 4];
    const points = [355, 402, 476, 290];
    final history = <HistoryEntry>[];
    for (var k = 1; k <= 4; k++) {
      final start = DateTime(monday.year, monday.month, monday.day - 7 * k);
      final end = DateTime(start.year, start.month, start.day + 6);
      history.add(HistoryEntry(
        label: 'Sem. ${rangeLabel(start, end)}',
        winnerId: winners[k - 1],
        userRank: ranks[k - 1],
        userPoints: points[k - 1],
      ));
    }

    return RankingBoard(
      period: RankingPeriod.weekly,
      periodLabel: 'Semana del ${rangeLabel(monday, sunday)}',
      resetLabel: daysLeft <= 1
          ? 'Se reinicia mañana (lunes)'
          : 'Se reinicia en $daysLeft días (lunes)',
      entries: entries,
      totalChallenges: 12,
      chartLabels: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
      userSeries: _cumulative(
        const [0.8, 1.0, 1.4, 0.6, 1.2, 1.5, 1.0],
        todayIndex,
        userBase,
      ),
      groupSeries: _cumulative(
        const [1.0, 1.1, 1.0, 1.2, 1.0, 1.3, 0.9],
        todayIndex,
        groupAverage,
      ),
      history: history,
    );
  }

  static RankingBoard _monthlyBoard(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(now.year, now.month + 1, 1);
    final daysLeft = next.difference(today).inDays;
    final weekIndex = ((today.day - 1) ~/ 7) > 3 ? 3 : (today.day - 1) ~/ 7;

    const entries = [
      RankingEntry(memberId: 'u-002', points: 1840, completed: 38, wins: 11, previousRank: 1),
      RankingEntry(memberId: 'u-003', points: 1610, completed: 34, wins: 9, previousRank: 2),
      RankingEntry(memberId: 'u-001', points: 1420, completed: 29, wins: 6, previousRank: 3),
      RankingEntry(memberId: 'u-004', points: 1250, completed: 26, wins: 5, previousRank: 4),
      RankingEntry(memberId: 'u-005', points: 980, completed: 21, wins: 3, previousRank: 5),
    ];

    final userBase =
        entries.firstWhere((e) => e.memberId == 'u-001').points.toDouble();
    final groupAverage =
        entries.fold<int>(0, (sum, e) => sum + e.points) / entries.length;

    const winners = ['u-002', 'u-003', 'u-001'];
    const ranks = [3, 2, 1];
    const points = [1390, 1540, 1710];
    final history = <HistoryEntry>[];
    for (var k = 1; k <= 3; k++) {
      final month = DateTime(now.year, now.month - k, 1);
      history.add(HistoryEntry(
        label: '${kMonthsLong[month.month - 1]} ${month.year}',
        winnerId: winners[k - 1],
        userRank: ranks[k - 1],
        userPoints: points[k - 1],
      ));
    }

    return RankingBoard(
      period: RankingPeriod.monthly,
      periodLabel: '${kMonthsLong[now.month - 1]} ${now.year}',
      resetLabel: daysLeft <= 1
          ? 'Cierra mañana'
          : 'Cierra en $daysLeft días · se reinicia el 1 de ${kMonthsLong[next.month - 1].toLowerCase()}',
      entries: entries,
      totalChallenges: 45,
      chartLabels: const ['S1', 'S2', 'S3', 'S4'],
      userSeries: _cumulative(const [1.0, 1.2, 1.1, 1.3], weekIndex, userBase),
      groupSeries:
          _cumulative(const [1.0, 1.1, 1.0, 1.2], weekIndex, groupAverage),
      history: history,
    );
  }

  // --- Tienda ----------------------------------------------------------------

  static List<StoreItem> storeItems() {
    return const [
      StoreItem(
        id: StoreItem.doubleXpId,
        name: 'Doble XP',
        description: 'Tu próximo reto completado te da el doble de XP.',
        price: 90,
        icon: Icons.bolt_rounded,
        kind: StoreItemKind.advantage,
      ),
      StoreItem(
        id: 'streak_shield',
        name: 'Escudo de racha',
        description: 'Protege tu racha si un día no alcanzas a completar el reto.',
        price: 120,
        icon: Icons.shield_rounded,
        kind: StoreItemKind.advantage,
      ),
      StoreItem(
        id: 'extra_time',
        name: 'Tiempo extra',
        description: '30 minutos más en la ventana de un reto.',
        price: 60,
        icon: Icons.more_time_rounded,
        kind: StoreItemKind.advantage,
      ),
      StoreItem(
        id: 'swap_challenge',
        name: 'Cambio de reto',
        description: 'Cambia un reto que no te guste por otro de su misma dificultad.',
        price: 80,
        icon: Icons.swap_horiz_rounded,
        kind: StoreItemKind.advantage,
      ),
      StoreItem(
        id: 'pick_challenge',
        name: 'Tú eliges',
        description: 'Propón el próximo reto para todo el bonche.',
        price: 200,
        icon: Icons.lightbulb_rounded,
        kind: StoreItemKind.reward,
      ),
      StoreItem(
        id: 'avatar_frame',
        name: 'Marco dorado',
        description: 'Un marco dorado para tu avatar en el Bonche.',
        price: 150,
        icon: Icons.account_circle_rounded,
        kind: StoreItemKind.reward,
        oneTime: true,
      ),
      StoreItem(
        id: 'stickers',
        name: 'Stickers del bonche',
        description: 'Un pack de stickers para la charla del grupo.',
        price: 70,
        icon: Icons.celebration_rounded,
        kind: StoreItemKind.reward,
        oneTime: true,
      ),
    ];
  }
}