import 'package:flutter/material.dart';

enum StoreItemKind { advantage, reward }

enum PurchaseResult { success, insufficientCoins, alreadyOwned }

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
  final StoreItemKind kind;

  /// Si es true solo se puede comprar una vez (cosméticos).
  final bool oneTime;

  bool get appliesAutomatically => id == doubleXpId;
}