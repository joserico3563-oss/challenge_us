import '../data/mock_data.dart';
import '../models/models.dart';

/// Chat del Bonche. Por ahora simulado; un servidor lo reemplazará después.
abstract class ChatService {
  Future<List<ChatMessage>> fetchMessages();

  Future<ChatMessage> replyTo({
    required String text,
    required List<GroupMember> members,
    required String excludeId,
    required int seed,
  });
}

class MockChatService implements ChatService {
  const MockChatService();

  static const List<String> _replies = [
    'Jajaja, eso es tener actitud.',
    'Ya voy yo también, no me dejen atrás.',
    'Eso, parcero, así se hace.',
    '¿Quién va ganando esta semana? Me toca remontar.',
    'Hoy sí que se puso buena la cosa.',
  ];

  @override
  Future<List<ChatMessage>> fetchMessages() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.chatMessages(DateTime.now());
  }

  @override
  Future<ChatMessage> replyTo({
    required String text,
    required List<GroupMember> members,
    required String excludeId,
    required int seed,
  }) async {
    final candidates = members.where((m) => m.id != excludeId).toList();
    final author =
        candidates.isEmpty ? null : candidates[seed % candidates.length];
    return ChatMessage(
      id: 'r-${DateTime.now().microsecondsSinceEpoch}',
      authorId: author?.id,
      text: _replies[seed % _replies.length],
      sentAt: DateTime.now(),
    );
  }
}