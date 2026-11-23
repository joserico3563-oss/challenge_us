import 'package:flutter/material.dart' show IconData, Icons;

import '../models/models.dart';
import 'api_service.dart';
import 'chat_service.dart';
import 'ranking_service.dart';
import 'store_service.dart';

/// Ranking real del bonche: GET /api/bonches/{id}/ranking.
/// Ordena solo por la XP ganada en el periodo (semanal o mensual).
class ApiRankingService implements RankingService {
  const ApiRankingService();

  @override
  Future<RankingBoard?> fetchBoard(
    RankingPeriod period,
    DateTime now, {
    String boncheId = '',
  }) async {
    if (boncheId.isEmpty) return null;
    final data = await ApiService.getBoncheRanking(
      boncheId,
      period == RankingPeriod.weekly ? 'weekly' : 'monthly',
    );

    final entries = <RankingEntry>[];
    final raw = data['entries'];
    if (raw is List) {
      for (var i = 0; i < raw.length; i++) {
        final item = raw[i];
        if (item is! Map<String, dynamic>) continue;
        entries.add(
          RankingEntry(
            memberId: (item['userId'] ?? '').toString(),
            name: (item['name'] ?? '').toString(),
            points: (item['xp'] as num?)?.toInt() ?? 0,
            completed: (item['completed'] as num?)?.toInt() ?? 0,
            wins: 0,
            previousRank: i + 1,
          ),
        );
      }
    }
    if (entries.isEmpty) return null;

    return RankingBoard(
      period: period,
      periodLabel: (data['label'] ?? '').toString(),
      resetLabel: (data['resetLabel'] ?? '').toString(),
      entries: entries,
      totalChallenges: (data['totalChallenges'] as num?)?.toInt() ?? 0,
      chartLabels: _strings(data['chartLabels']),
      userSeries: _numbers(data['userSeries']),
      groupSeries: _numbers(data['groupSeries']),
      history: _history(data['history']),
    );
  }

  static List<String> _strings(dynamic raw) {
    if (raw is! List) return const <String>[];
    return [for (final x in raw) x.toString()];
  }

  static List<double> _numbers(dynamic raw) {
    if (raw is! List) return const <double>[];
    return [
      for (final x in raw)
        if (x is num) x.toDouble(),
    ];
  }

  static List<HistoryEntry> _history(dynamic raw) {
    if (raw is! List) return const <HistoryEntry>[];
    final result = <HistoryEntry>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      result.add(
        HistoryEntry(
          label: (item['label'] ?? '').toString(),
          winnerId: (item['winnerId'] ?? '').toString(),
          userRank: (item['userRank'] as num?)?.toInt() ?? 0,
          userPoints: (item['userXp'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return result;
  }
}
/// Chat desactivado.
class ApiChatService implements ChatService {
  const ApiChatService();

  @override
  Future<List<ChatMessage>> fetchMessages() async => const [];

  @override
  Future<ChatMessage> replyTo({
    required String text,
    required List<GroupMember> members,
    required String excludeId,
    required int seed,
  }) {
    throw UnsupportedError('El chat esta desactivado.');
  }
}

/// Tienda vacia por ahora.
class ApiStoreService implements StoreService {
  const ApiStoreService();

  @override
  Future<List<StoreItem>> fetchItems() async {
    final items = await ApiService.getStoreItems();
    return [
      for (final item in items)
        StoreItem(
          id: item.id,
          name: item.name,
          description: item.description,
          price: item.price,
          icon: _storeIcon(item.icon),
          kind: item.kind == 'reward'
              ? StoreItemKind.reward
              : StoreItemKind.advantage,
          oneTime: item.oneTime,
        ),
    ];
  }
}
IconData _storeIcon(String name) {
  switch (name) {
    case 'bolt':
      return Icons.bolt_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'more_time':
      return Icons.more_time_rounded;
    case 'swap':
      return Icons.swap_horiz_rounded;
    case 'lightbulb':
      return Icons.lightbulb_rounded;
    case 'account_circle':
      return Icons.account_circle_rounded;
    case 'celebration':
      return Icons.celebration_rounded;
    default:
      return Icons.card_giftcard_rounded;
  }
}