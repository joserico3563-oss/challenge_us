import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// BONCHE
// -----------------------------------------------------------------------------

class BoncheScreen extends StatelessWidget {
  const BoncheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (state.socialLoading) {
      return const LoadingView(label: 'Cargando tu bonche...');
    }
    final error = state.socialError;
    if (error != null) {
      return ErrorStateView(message: error, onRetry: () => state.loadSocial());
    }
    final group = state.group;
    if (group == null) {
      return const EmptyStateView(
        icon: Icons.groups_rounded,
        title: 'Aún no tienes bonche',
        message: 'Cuando te unas a un grupo privado, aparecerá aquí.',
      );
    }

    final members = state.members;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _GroupHeaderCard(
          group: group,
          memberCount: members.length,
          leader: state.memberById(group.leaderId),
        ),
        const SizedBox(height: 12),
        _InviteCodeCard(code: group.inviteCode),
        const SizedBox(height: 28),
        const SectionTitle('Integrantes'),
        _MembersCard(
          members: members,
          leaderId: group.leaderId,
          myId: state.user.id,
        ),
        const SizedBox(height: 28),
        const SectionTitle('Retos del bonche'),
        _ChallengeSettings(group: group, totalMembers: members.length),
        const SizedBox(height: 28),
        const SectionTitle('Charla del bonche'),
        const _ChatCard(),
      ],
    );
  }
}

class _GroupHeaderCard extends StatelessWidget {
  const _GroupHeaderCard({
    required this.group,
    required this.memberCount,
    required this.leader,
  });

  final GroupInfo group;
  final int memberCount;
  final GroupMember? leader;

  @override
  Widget build(BuildContext context) {
    final since = '${kMonthsLong[group.createdAt.month - 1].toLowerCase()} de ${group.createdAt.year}';

    return CCCard(
      highlight: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.onYellow,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: AppText.title),
                    const SizedBox(height: 4),
                    Text(group.tagline, style: AppText.bodyMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const InfoPill(
                label: 'Grupo privado',
                icon: Icons.lock_rounded,
                color: AppColors.yellow,
              ),
              InfoPill(label: '$memberCount integrantes', icon: Icons.groups_rounded),
              InfoPill(
                label: 'Líder: ${leader?.firstName ?? '-'}',
                icon: Icons.workspace_premium_rounded,
                color: AppColors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Activo desde $since', style: AppText.label),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code});

  final String code;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado. ¡Compártelo con tu parche!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.vpn_key_rounded, color: AppColors.yellow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CÓDIGO DE INVITACIÓN', style: AppText.label),
                    const SizedBox(height: 2),
                    Text(
                      code,
                      style: AppText.heading.copyWith(letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.content_copy_rounded, size: 18),
                label: const Text('Copiar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'El bonche es privado: solo entra quien tenga este código.',
            style: AppText.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.members,
    required this.leaderId,
    required this.myId,
  });

  final List<GroupMember> members;
  final String leaderId;
  final String myId;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            _MemberRow(
              member: members[i],
              isLeader: members[i].id == leaderId,
              isMe: members[i].id == myId,
            ),
            if (i != members.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isLeader,
    required this.isMe,
  });

  final GroupMember member;
  final bool isLeader;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          UserAvatar(initials: member.initials, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(member.name, style: AppText.heading),
                    if (isLeader)
                      const InfoPill(
                        label: 'Líder',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.orange,
                      ),
                    if (isMe)
                      const InfoPill(label: 'Tú', color: AppColors.yellow),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Nivel ${member.level}', style: AppText.bodyMuted),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 2),
                    Text('${member.streak}', style: AppText.bodyMuted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeSettings extends StatelessWidget {
  const _ChallengeSettings({required this.group, required this.totalMembers});

  final GroupInfo group;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatBox(
                icon: Icons.bolt_rounded,
                value: '${group.dailyChallenges}',
                label: 'RETOS AL DÍA',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBox(
                icon: Icons.timer_outlined,
                value: windowLabel(group.windowMinutes),
                label: 'POR RETO',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBox(
                icon: Icons.groups_rounded,
                value: '$totalMembers',
                label: 'INTEGRANTES',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CCCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('HORARIOS', style: AppText.label),
              const SizedBox(height: 12),
              for (final schedule in group.schedules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ScheduleRow(schedule: schedule, totalMembers: totalMembers),
                ),
              Text(
                'Cada reto dura ${windowLabel(group.windowMinutes)}. Los horarios se eligen para coincidir con el momento en que más integrantes están disponibles.',
                style: AppText.bodyMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CCCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CATEGORÍAS', style: AppText.label),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in group.categories)
                    InfoPill(
                      label: category.label,
                      icon: category.icon,
                      color: AppColors.yellow,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Solo el líder puede cambiar horarios y categorías.',
                style: AppText.bodyMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.schedule, required this.totalMembers});

  final GroupSchedule schedule;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    final everyone = schedule.availableMembers >= totalMembers;
    final ratio =
        totalMembers == 0 ? 0.0 : schedule.availableMembers / totalMembers;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.yellowSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.schedule_rounded, color: AppColors.yellow),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(schedule.label, style: AppText.heading),
                  Text(
                    '${schedule.availableMembers}/$totalMembers disponibles',
                    style: AppText.label,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CCProgressBar(
                value: ratio,
                height: 6,
                color: everyone ? AppColors.success : AppColors.yellow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatCard extends StatefulWidget {
  const _ChatCard();

  @override
  State<_ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<_ChatCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    AppScope.read(context).sendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = state.messages;
    final visible = all.length > 8 ? all.sublist(all.length - 8) : all;
    final myId = state.user.id;

    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.yellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Conversación del grupo', style: AppText.heading)),
              const InfoPill(label: 'Demo'),
            ],
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Sé el primero en escribirle al bonche.',
                style: AppText.bodyMuted,
              ),
            )
          else
            for (final message in visible)
              _ChatBubble(
                message: message,
                author: message.authorId == null
                    ? null
                    : state.memberById(message.authorId!),
                isMine: message.authorId == myId,
              ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  minLines: 1,
                  maxLines: 3,
                  decoration: ccInputDecoration(
                    label: 'Escribe al bonche',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _send,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.onYellow,
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.author,
    required this.isMine,
  });

  final ChatMessage message;
  final GroupMember? author;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              InfoPill(
                label: message.text,
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ],
          ),
        ),
      );
    }

    final maxWidth = MediaQuery.sizeOf(context).width * 0.68;
    final textColor = isMine ? AppColors.onYellow : AppColors.textPrimary;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isMine ? AppColors.yellow : AppColors.surfaceAlt,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    author?.firstName ?? 'Bonchero',
                    style: AppText.label.copyWith(color: AppColors.yellow),
                  ),
                ),
              Text(message.text, style: AppText.body.copyWith(color: textColor)),
              const SizedBox(height: 4),
              Text(
                formatClock(message.sentAt),
                style: AppText.label.copyWith(
                  fontSize: 10,
                  color: isMine
                      ? AppColors.onYellow.withValues(alpha: 0.65)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}