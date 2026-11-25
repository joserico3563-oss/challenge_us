/// Evidencia de un compañero que el usuario todavía debe calificar.
class PendingEvidence {
  const PendingEvidence({
    required this.evidenceId,
    required this.boncheRetoId,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.challengeTitle,
    required this.votingEndsAt,
  });

  factory PendingEvidence.fromJson(Map<String, dynamic> json) {
    return PendingEvidence(
      evidenceId: (json['evidenceId'] ?? '').toString(),
      boncheRetoId: (json['boncheRetoId'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      ownerName: (json['ownerName'] ?? '').toString(),
      challengeTitle: (json['challengeTitle'] ?? '').toString(),
      votingEndsAt:
          DateTime.tryParse((json['votingEndsAt'] ?? '').toString())?.toLocal(),
    );
  }

  final String evidenceId;
  final String boncheRetoId;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final String challengeTitle;
  final DateTime? votingEndsAt;
}

/// Resultado de un reto ya cerrado (con o sin recompensa).
class RewardNotice {
  const RewardNotice({
    required this.id,
    required this.estado,
    required this.xp,
    required this.coins,
    required this.challengeTitle,
    required this.message,
  });

  factory RewardNotice.fromJson(Map<String, dynamic> json) {
    return RewardNotice(
      id: (json['id'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      challengeTitle: (json['challengeTitle'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  final String id;

  /// PAGADA, RECHAZADA o INCUMPLIDA.
  final String estado;
  final int xp;
  final int coins;
  final String challengeTitle;
  final String message;

  bool get paid => estado == 'PAGADA';
}

/// Estado propio de un reto del bonche (lo calcula el servidor).
class ChallengeProgress {
  const ChallengeProgress({
    required this.boncheRetoId,
    required this.submitted,
    required this.evidenceStatus,
    required this.reward,
    required this.submittedCount,
    this.attempts = 0,
    this.canRetry = false,
    this.closed = false,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      boncheRetoId: (json['boncheRetoId'] ?? '').toString(),
      submitted: json['submitted'] == true,
      evidenceStatus: json['evidenceStatus']?.toString(),
      reward: json['reward']?.toString(),
      submittedCount: (json['submittedCount'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      canRetry: json['canRetry'] == true,
      closed: json['closed'] == true,
    );
  }

  final String boncheRetoId;
  final bool submitted;
  final String? evidenceStatus;
  final String? reward;
  final int submittedCount;

  /// Evidencias que el usuario ya envio en este reto (maximo 2).
  final int attempts;

  /// Su evidencia fue rechazada y todavia puede enviar un segundo intento.
  final bool canRetry;
  final bool closed;
}

/// Artículo de la tienda tal como lo devuelve la API.
class StoreItemModel {
  const StoreItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.kind,
    required this.icon,
    required this.oneTime,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      kind: (json['kind'] ?? 'advantage').toString(),
      icon: (json['icon'] ?? '').toString(),
      oneTime: json['oneTime'] == true,
    );
  }

  final String id;
  final String name;
  final String description;
  final int price;
  final String kind;
  final String icon;
  final bool oneTime;
}

class InventoryEntry {
  const InventoryEntry({
    required this.itemId,
    required this.name,
    required this.quantity,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(
      itemId: (json['itemId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  final String itemId;
  final String name;
  final int quantity;
}

class PurchaseReceipt {
  const PurchaseReceipt({
    required this.coins,
    required this.itemId,
    required this.quantity,
  });

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      itemId: (json['itemId'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  final int coins;
  final String itemId;
  final int quantity;
}