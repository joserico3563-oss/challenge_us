// LA_RECOCHA_ENTREGA_FINAL

/// Tipos de notificación que entiende la app. El texto lo escribe el servidor.
enum NotificationKind {
  newChallenge,
  votesPending,
  evidenceApproved,
  evidenceRejected,
  retryAvailable,
  rewardReceived,
  noReward,
  other,
}

/// Notificación interna guardada en el servidor.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.boncheId,
    required this.refType,
    required this.refId,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      boncheId: json['boncheId']?.toString(),
      refType: json['refType']?.toString(),
      refId: json['refId']?.toString(),
      read: json['read'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal(),
    );
  }

  final String id;

  /// Código del servidor (NEW_CHALLENGE, VOTES_PENDING, ...).
  final String type;
  final String title;
  final String message;
  final String? boncheId;

  /// Qué referencia el [refId] (hoy siempre "bonche_reto").
  final String? refType;

  /// Para los retos coincide con el id de [Challenge].
  final String? refId;
  final bool read;
  final DateTime? createdAt;

  NotificationKind get kind {
    switch (type) {
      case 'NEW_CHALLENGE':
        return NotificationKind.newChallenge;
      case 'VOTES_PENDING':
        return NotificationKind.votesPending;
      case 'EVIDENCE_APPROVED':
        return NotificationKind.evidenceApproved;
      case 'EVIDENCE_REJECTED':
        return NotificationKind.evidenceRejected;
      case 'RETRY_AVAILABLE':
        return NotificationKind.retryAvailable;
      case 'REWARD_RECEIVED':
        return NotificationKind.rewardReceived;
      case 'NO_REWARD':
        return NotificationKind.noReward;
      default:
        return NotificationKind.other;
    }
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      boncheId: boncheId,
      refType: refType,
      refId: refId,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}

/// Respuesta de GET /api/notifications.
class NotificationInbox {
  const NotificationInbox({required this.items, required this.unreadCount});

  factory NotificationInbox.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return NotificationInbox(
      items: raw is List
          ? [
              for (final item in raw)
                if (item is Map<String, dynamic>)
                  AppNotification.fromJson(item),
            ]
          : const <AppNotification>[],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  final List<AppNotification> items;
  final int unreadCount;
}
