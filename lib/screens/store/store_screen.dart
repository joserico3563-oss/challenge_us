import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// TIENDA
// -----------------------------------------------------------------------------

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tab = 0;

  Future<void> _buy(StoreItem item) async {
    final state = AppScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirmar compra', style: AppText.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: AppText.title),
            const SizedBox(height: 8),
            Text(item.description, style: AppText.bodyMuted),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.yellow,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text('${item.price} monedas', style: AppText.heading),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = state.purchase(item);
    final message = switch (result) {
      PurchaseResult.success => '¡Listo! Compraste ${item.name}.',
      PurchaseResult.insufficientCoins =>
        'No te alcanzan las monedas para ${item.name}.',
      PurchaseResult.alreadyOwned => 'Ya tienes ${item.name}.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (state.socialLoading) {
      return const LoadingView(label: 'Abriendo la tienda...');
    }
    final error = state.socialError;
    if (error != null) {
      return ErrorStateView(message: error, onRetry: () => state.loadSocial());
    }
    if (state.storeItems.isEmpty) {
      return const EmptyStateView(
        icon: Icons.storefront_rounded,
        title: 'La tienda está vacía',
        message: 'Muy pronto habrá ventajas y recompensas para canjear.',
      );
    }

    final coins = state.user.coins;
    final kind = _tab == 0 ? StoreItemKind.advantage : StoreItemKind.reward;
    final shown = state.storeItems.where((item) => item.kind == kind).toList();
    final owned = state.storeItems
        .where((item) => state.ownedCount(item.id) > 0)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _CoinsCard(coins: coins),
        const SizedBox(height: 12),
        const CCCard(
          child: Row(
            children: [
              Icon(Icons.military_tech_rounded, color: AppColors.yellow, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Las insignias no se compran: se consiguen con logros dentro del bonche.',
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SegmentedTabs(
          labels: const ['Ventajas', 'Recompensas'],
          selected: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        for (final item in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StoreItemCard(
              item: item,
              owned: state.ownedCount(item.id),
              coins: coins,
              onBuy: () => _buy(item),
            ),
          ),
        if (owned.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionTitle('Tu mochila'),
          CCCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < owned.length; i++) ...[
                  _InventoryRow(
                    item: owned[i],
                    count: state.ownedCount(owned[i].id),
                  ),
                  if (i != owned.length - 1)
                    const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CoinsCard extends StatelessWidget {
  const _CoinsCard({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      highlight: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.onYellow,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TUS MONEDAS', style: AppText.label),
                const SizedBox(height: 2),
                Text('$coins', style: AppText.display),
                const SizedBox(height: 2),
                const Text(
                  'Las ganas completando retos.',
                  style: AppText.bodyMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  const _StoreItemCard({
    required this.item,
    required this.owned,
    required this.coins,
    required this.onBuy,
  });

  final StoreItem item;
  final int owned;
  final int coins;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final soldOut = item.oneTime && owned > 0;
    final canAfford = coins >= item.price;

    final String buttonLabel;
    if (soldOut) {
      buttonLabel = 'Adquirido';
    } else if (!canAfford) {
      buttonLabel = 'Te faltan ${item.price - coins}';
    } else {
      buttonLabel = 'Comprar';
    }

    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: AppColors.yellow, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(item.name, style: AppText.heading),
                        if (owned > 0 && !item.oneTime)
                          InfoPill(label: 'Tienes $owned', color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, style: AppText.bodyMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.yellow,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text('${item.price}', style: AppText.title),
              const Spacer(),
              FilledButton(
                onPressed: (soldOut || !canAfford) ? null : onBuy,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(128, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item, required this.count});

  final StoreItem item;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.yellowSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.yellow, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  item.appliesAutomatically
                      ? 'Se aplica sola en tu próximo reto'
                      : 'Guardada en tu mochila',
                  style: AppText.bodyMuted,
                ),
              ],
            ),
          ),
          Text('x$count', style: AppText.heading),
        ],
      ),
    );
  }
}