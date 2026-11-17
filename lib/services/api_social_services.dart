import '../models/models.dart';
import 'chat_service.dart';
import 'ranking_service.dart';
import 'store_service.dart';

/// Sin ranking hasta que el backend lo exponga por bonche.
class ApiRankingService implements RankingService {
  const ApiRankingService();

  @override
  Future<RankingBoard?> fetchBoard(RankingPeriod period, DateTime now) async =>
      null;
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
  Future<List<StoreItem>> fetchItems() async => const [];
}