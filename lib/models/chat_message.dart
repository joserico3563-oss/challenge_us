class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.sentAt,
  });

  /// Mensaje automático del sistema (por ejemplo, "X completó un reto").
  factory ChatMessage.system({
    required String id,
    required String text,
    required DateTime sentAt,
  }) {
    return ChatMessage(id: id, authorId: null, text: text, sentAt: sentAt);
  }

  final String id;
  final String? authorId;
  final String text;
  final DateTime sentAt;

  bool get isSystem => authorId == null;
}