import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Calificar las evidencias de los compañeros
// -----------------------------------------------------------------------------

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String? _busyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).refreshCycle();
    });
  }

  Future<void> _vote(PendingEvidence evidence, bool approve) async {
    if (_busyId != null) return;
    final app = AppScope.read(context);
    setState(() => _busyId = evidence.evidenceId);
    final error = await app.castVote(evidence, approve: approve);
    if (!mounted) return;
    setState(() => _busyId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Voto enviado. No se puede cambiar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TickBuilder(
      builder: (context, now) {
        final state = AppScope.of(context);
        final items = state.pendingVotes;

        return RecochaScaffold(
          appBar: ccAppBar('Calificar evidencias'),
          body: items.isEmpty
              ? const EmptyStateView(
                  icon: Icons.how_to_vote_rounded,
                  title: 'Todo calificado',
                  message: 'Por el momento no hay ninguna evidencia o ya las calificaste todas.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    const Text(
                      'Aprueba o rechaza las fotos de tu bonche. Tu voto no se puede cambiar y debes calificarlas todas para recibir tus recompensas.',
                      style: AppText.bodyMuted,
                    ),
                    const SizedBox(height: 16),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EvidenceVoteCard(
                          evidence: item,
                          now: now,
                          busy: _busyId == item.evidenceId,
                          disabled: _busyId != null,
                          onApprove: () => _vote(item, true),
                          onReject: () => _vote(item, false),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _EvidenceVoteCard extends StatelessWidget {
  const _EvidenceVoteCard({
    required this.evidence,
    required this.now,
    required this.busy,
    required this.disabled,
    required this.onApprove,
    required this.onReject,
  });

  final PendingEvidence evidence;
  final DateTime now;
  final bool busy;
  final bool disabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final end = evidence.votingEndsAt;
    final remaining = end?.difference(now);
    final timeText = remaining == null
        ? null
        : (remaining.isNegative
              ? 'Cerrando la votación...'
              : 'Cierra en ${formatRemaining(remaining)}');

    return CCCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(evidence.challengeTitle, style: AppText.heading),
          const SizedBox(height: 2),
          Text('Foto de ${evidence.ownerName}', style: AppText.bodyMuted),
          if (timeText != null) ...[
            const SizedBox(height: 8),
            InfoPill(
              label: timeText,
              icon: Icons.timer_outlined,
              color: AppColors.yellow,
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              evidence.imageUrl,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 320,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Rechazar',
                  icon: Icons.close_rounded,
                  onPressed: disabled ? null : onReject,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Aprobar',
                  icon: Icons.check_rounded,
                  loading: busy,
                  onPressed: disabled ? null : onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
