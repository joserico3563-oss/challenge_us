import '../profile/open_member_profile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 64,
                color: AppColors.yellow,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ya no tienes Bonche',
                style: AppText.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea otro Bonche o únete al de tus amigos.',
                textAlign: TextAlign.center,
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Crear o unirme a un Bonche',
                onPressed: () =>
                    Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.boncheSetup,
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
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
        if (state.isLeader) ...[
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Editar bonche y retos',
            icon: Icons.edit_rounded,
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.boncheConfig, arguments: false),
          ),
        ],
        const SizedBox(height: 28),
        const SectionTitle('Calificar evidencias'),
        _VotesCard(
          count: state.pendingVotes.length,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.vote),
        ),
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
        if (!state.isLeader || members.length > 1) ...[
          const SizedBox(height: 28),
          _LeaveBoncheButton(
            groupId: group.id,
            isLeader: state.isLeader,
          ),
        ],
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
    final since =
        '${kMonthsLong[group.createdAt.month - 1].toLowerCase()} de ${group.createdAt.year}';

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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/larecocha/navigation/bonche.png',
                  fit: BoxFit.contain,
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
              InfoPill(
                label: '$memberCount integrantes',
                icon: Icons.groups_rounded,
              ),
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
      const SnackBar(
        content: Text('Código copiado. ¡Compártelo con tu parche!'),
      ),
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
                child: const Icon(
                  Icons.vpn_key_rounded,
                  color: AppColors.yellow,
                ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => openMemberProfile(context, member.id),
      child: Padding(
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
                  child: _ScheduleRow(
                    schedule: schedule,
                    totalMembers: totalMembers,
                  ),
                ),
              Text(
                'Cada reto dura ${windowLabel(group.windowMinutes)}. Los horarios se eligen para coincidir con el momento en que más integrantes están disponibles.',
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
    final ratio = totalMembers == 0
        ? 0.0
        : schedule.availableMembers / totalMembers;

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
                  Text('Todos los días', style: AppText.label),
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

class _VotesCard extends StatelessWidget {
  const _VotesCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = count == 0;
    final title = empty
        ? 'Por el momento no hay ninguna evidencia o ya las calificaste todas.'
        : (count == 1
              ? 'Tienes 1 evidencia por calificar'
              : 'Tienes $count evidencias por calificar');

    return CCCard(
      highlight: !empty,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_vote_rounded, color: AppColors.yellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: empty ? AppText.bodyMuted : AppText.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Calificar evidencias',
            icon: Icons.arrow_forward_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}


class _LeaveBoncheButton extends StatefulWidget {
  const _LeaveBoncheButton({
    required this.groupId,
    required this.isLeader,
  });

  final String groupId;
  final bool isLeader;

  @override
  State<_LeaveBoncheButton> createState() => _LeaveBoncheButtonState();
}

class _LeaveBoncheButtonState extends State<_LeaveBoncheButton> {
  bool _busy = false;

  Future<void> _leave() async {
    if (_busy) return;

    final app = AppScope.read(context);

    setState(() => _busy = true);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.error,
          size: 42,
        ),
        title: const Text(
          '\u00bfVas a salir del Bonche?',
          textAlign: TextAlign.center,
          style: AppText.heading,
        ),
        content: Text(
          'Dejar\u00e1s de participar en los retos y el ranking de este Bonche.\n\n'
          'Conservar\u00e1s tus XP, Barras y compras.'
          '${widget.isLeader ? "\n\nEl integrante con mayor antig\u00fcedad se convertir\u00e1 en el nuevo l\u00edder." : ""}',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Salir del Bonche'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed != true) {
      setState(() => _busy = false);
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final error = await app.leaveCurrentGroup(widget.groupId);

    if (!navigator.mounted) return;

    if (error != null) {
      if (mounted) setState(() => _busy = false);
      if (messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      app.group == null ? AppRoutes.boncheSetup : AppRoutes.main,
      (route) => false,
    );

    if (messenger.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Has salido del Bonche.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _leave,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(
        _busy ? 'Saliendo del Bonche...' : 'Salir del Bonche',
      ),
    );
  }
}
