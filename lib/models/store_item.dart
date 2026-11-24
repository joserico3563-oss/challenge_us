import 'package:flutter/material.dart';

enum StoreItemKind { advantage, reward }

enum PurchaseResult { success, insufficientCoins, alreadyOwned, failed }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.kind,
    this.oneTime = false,
  });

  /// Única ventaja con efecto real por ahora: duplica el XP del próximo reto.
  static const String doubleXpId = 'double_xp';

  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;

  String? get assetPath => switch (id) {
    'double_xp' => 'assets/larecocha/shop/doblexp.png',
    'streak_shield' => 'assets/larecocha/shop/bloquearracha.png',
    'extra_time' => 'assets/larecocha/shop/tiempoextra.png',
    'swap_challenge' => 'assets/larecocha/shop/cambiarreto.png',
    'pick_challenge' => 'assets/larecocha/shop/escogerreto.png',
    'avatar_frame' => 'assets/larecocha/shop/marcodorado.png',
    'stickers' => 'assets/larecocha/branding/stickers.png',
    _ => null,
  };

  final StoreItemKind kind;

  /// Si es true solo se puede comprar una vez (cosméticos).
  final bool oneTime;

  bool get appliesAutomatically => id == doubleXpId;
}
