// LA_RECOCHA_ENTREGA_FINAL
import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Centro de notificaciones internas
// -----------------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).refreshCycle();
    });
  }

  /// Marca la notificación como leída y abre la pantalla relacionada.
  void _open(AppState state, AppNotification item) {
    unawaited(state.markNotificationRead(item));
    final navigator = Navigator.of(context);
    switch (item.kind) {
      case NotificationKind.votesPending:
        navigator.pushNamed(AppRoutes.vote);
        return;
      case NotificationKind.other:
        return;
      case NotificationKind.newChallenge:
      case NotificationKind.evidenceApproved:
      case NotificationKind.evidenceRejected:
      case NotificationKind.retryAvailable:
      case NotificationKind.rewardReceived:
      case NotificationKind.noReward:
        final id = item.refId;
        if (id != null && id.isNotEmpty && state.challengeById(id) != null) {
          navigator.pushNamed(AppRoutes.challengeDetail, arguments: id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ese reto ya no está disponible.')),
          );
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TickBuilder(
      builder: (context, now) {
        final state = AppScope.of(context);
        final items = state.notifications;
        final unread = state.unreadNotifications;

        return Scaffold(
          appBar: ccAppBar(
            'Notificaciones',
            actions: [
              if (unread > 0)
                TextButton(
                  onPressed: () => state.markAllNotificationsRead(),
                  child: const Text('Marcar todo'),
                ),
            ],
          ),
          body: items.isEmpty
              ? const EmptyStateView(
                  icon: Icons.notifications_none_rounded,
                  title: 'Sin notificaciones',
                  message:
                      'Aquí verás cuando salga un reto nuevo, tengas evidencias por calificar o recibas una recompensa.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        unread == 0
                            ? 'Estás al día.'
                            : (unread == 1
                                ? 'Tienes 1 notificación sin leer'
                                : 'Tienes $unread notificaciones sin leer'),
                        style: AppText.bodyMuted,
                      ),
                    ),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationTile(
                          item: item,
                          now: now,
                          onTap: () => _open(state, item),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.now,
    required this.onTap,
  });

  final AppNotification item;
  final DateTime now;
  final VoidCallback onTap;

  static IconData _icon(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.newChallenge:
        return Icons.flag_rounded;
      case NotificationKind.votesPending:
        return Icons.how_to_vote_rounded;
      case NotificationKind.evidenceApproved:
        return Icons.check_circle_rounded;
      case NotificationKind.evidenceRejected:
        return Icons.cancel_rounded;
      case NotificationKind.retryAvailable:
        return Icons.replay_rounded;
      case NotificationKind.rewardReceived:
        return Icons.emoji_events_rounded;
      case NotificationKind.noReward:
        return Icons.info_outline_rounded;
      case NotificationKind.other:
        return Icons.notifications_rounded;
    }
  }

  static Color _color(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.evidenceApproved:
      case NotificationKind.rewardReceived:
        return AppColors.success;
      case NotificationKind.evidenceRejected:
        return AppColors.error;
      case NotificationKind.retryAvailable:
        return AppColors.orange;
      case NotificationKind.noReward:
        return AppColors.textSecondary;
      case NotificationKind.newChallenge:
      case NotificationKind.votesPending:
      case NotificationKind.other:
        return AppColors.yellow;
    }
  }

  static String _ago(DateTime? when, DateTime now) {
    if (when == null) return '';
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${two(when.day)}/${two(when.month)}/${when.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(item.kind);
    final ago = _ago(item.createdAt, now);

    return CCCard(
      highlight: !item.read,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon(item.kind), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: item.read
                            ? AppText.body.copyWith(fontWeight: FontWeight.w600)
                            : AppText.heading,
                      ),
                    ),
                    if (!item.read)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.message, style: AppText.bodyMuted),
                if (ago.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(ago, style: AppText.label),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
