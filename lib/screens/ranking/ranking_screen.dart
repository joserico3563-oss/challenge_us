import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// RANKING
// -----------------------------------------------------------------------------

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingPeriod _period = RankingPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (state.socialLoading) {
      return const LoadingView(label: 'Cargando el ranking...');
    }
    final error = state.socialError;
    if (error != null) {
      return ErrorStateView(message: error, onRetry: () => state.loadSocial());
    }
    final board = state.boardFor(_period);
    if (board == null) {
      return const EmptyStateView(
        icon: Icons.leaderboard_rounded,
        title: 'Aún no hay ranking',
        message: 'Completa retos con tu bonche y aquí verás la clasificación.',
      );
    }

    final entries = state.liveEntries(_period);
    final myIndex = entries.indexWhere((e) => e.memberId == state.user.id);
    final me = myIndex >= 0 ? entries[myIndex] : null;
    final groupAverage =
        board.groupSeries.isEmpty ? 0 : board.groupSeries.last.round();
    final myPoints = me?.points ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        SegmentedTabs(
          labels: const ['Semanal', 'Mensual'],
          selected: _period == RankingPeriod.weekly ? 0 : 1,
          onChanged: (i) => setState(() {
            _period = i == 0 ? RankingPeriod.weekly : RankingPeriod.monthly;
          }),
        ),
        const SizedBox(height: 16),
        _PeriodHeaderCard(board: board),
        const SizedBox(height: 20),
        if (entries.length >= 3) ...[
          _Podium(entries: entries, state: state),
          const SizedBox(height: 24),
        ],
        const SectionTitle('Tabla de posiciones'),
        _StandingsCard(entries: entries, state: state),
        if (me != null) ...[
          const SizedBox(height: 28),
          const SectionTitle('Tus estadísticas'),
          _MyStats(
            rank: myIndex + 1,
            entry: me,
            totalChallenges: board.totalChallenges,
          ),
        ],
        const SizedBox(height: 28),
        const SectionTitle('Evolución'),
        CCCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: CustomPaint(
                  painter: _EvolutionChartPainter(
                    labels: board.chartLabels,
                    userValues: state.liveUserSeries(_period),
                    groupValues: board.groupSeries,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  _LegendDot(color: AppColors.yellow, label: 'Tú'),
                  SizedBox(width: 16),
                  _LegendDot(
                    color: AppColors.textSecondary,
                    label: 'Promedio del bonche',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Llevas $myPoints puntos; el promedio del bonche es $groupAverage.',
                style: AppText.bodyMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionTitle('Historial'),
        _HistoryCard(board: board, state: state),
        const SizedBox(height: 16),
        Text(
          _period == RankingPeriod.weekly
              ? 'El ranking semanal se reinicia cada lunes. Tu historial se conserva.'
              : 'El ranking mensual se reinicia cada mes. Tu historial se conserva.',
          textAlign: TextAlign.center,
          style: AppText.label,
        ),
      ],
    );
  }
}

class _PeriodHeaderCard extends StatelessWidget {
  const _PeriodHeaderCard({required this.board});

  final RankingBoard board;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.yellow,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(board.periodLabel, style: AppText.heading)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.restart_alt_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(board.resetLabel, style: AppText.bodyMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.state});

  final List<RankingEntry> entries;
  final AppState state;

  Widget _slot(int rank, RankingEntry entry, double barHeight, Color color) {
    final member = state.memberById(entry.memberId);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank == 1)
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.yellow,
              size: 28,
            )
          else
            const SizedBox(height: 28),
          UserAvatar(
            initials: member?.initials ?? '?',
            radius: rank == 1 ? 30 : 24,
          ),
          const SizedBox(height: 8),
          Text(
            member?.firstName ?? 'Jugador',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text('${entry.points} pts', style: AppText.label),
          const SizedBox(height: 8),
          Container(
            height: barHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Text('$rank', style: AppText.title.copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _slot(2, entries[1], 84, AppColors.silver),
        _slot(1, entries[0], 112, AppColors.yellow),
        _slot(3, entries[2], 64, AppColors.orange),
      ],
    );
  }
}

class _StandingsCard extends StatelessWidget {
  const _StandingsCard({required this.entries, required this.state});

  final List<RankingEntry> entries;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 22, child: Text('#', style: AppText.label)),
                SizedBox(width: 30),
                SizedBox(width: 46),
                Expanded(child: Text('JUGADOR', style: AppText.label)),
                SizedBox(
                  width: 44,
                  child: Text('RETOS', textAlign: TextAlign.center, style: AppText.label),
                ),
                SizedBox(
                  width: 60,
                  child: Text('PTS', textAlign: TextAlign.right, style: AppText.label),
                ),
              ],
            ),
          ),
          for (var i = 0; i < entries.length; i++)
            _StandingRow(
              rank: i + 1,
              entry: entries[i],
              member: state.memberById(entries[i].memberId),
              isMe: entries[i].memberId == state.user.id,
            ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.rank,
    required this.entry,
    required this.member,
    required this.isMe,
  });

  final int rank;
  final RankingEntry entry;
  final GroupMember? member;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final delta = entry.previousRank - rank;
    final winsText = '${entry.wins} ${entry.wins == 1 ? 'victoria' : 'victorias'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isMe ? AppColors.yellowSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank',
              style: AppText.heading.copyWith(
                color: rank == 1 ? AppColors.yellow : AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 30, child: _RankDelta(delta: delta)),
          UserAvatar(initials: member?.initials ?? '?', radius: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '${member?.firstName ?? 'Tú'} (tú)' : member?.firstName ?? 'Jugador',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(winsText, style: AppText.label.copyWith(fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${entry.completed}',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${entry.points}',
              textAlign: TextAlign.right,
              style: AppText.heading,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankDelta extends StatelessWidget {
  const _RankDelta({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    if (delta == 0) {
      return const Icon(
        Icons.remove_rounded,
        size: 16,
        color: AppColors.textSecondary,
      );
    }
    final up = delta > 0;
    final color = up ? AppColors.success : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          size: 20,
          color: color,
        ),
        Text(
          '${delta.abs()}',
          style: AppText.label.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

class _MyStats extends StatelessWidget {
  const _MyStats({
    required this.rank,
    required this.entry,
    required this.totalChallenges,
  });

  final int rank;
  final RankingEntry entry;
  final int totalChallenges;

  @override
  Widget build(BuildContext context) {
    final percent = totalChallenges == 0
        ? 0
        : ((entry.completed * 100) / totalChallenges).clamp(0, 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatBox(
                icon: Icons.leaderboard_rounded,
                value: '#$rank',
                label: 'PUESTO',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBox(
                icon: Icons.stars_rounded,
                value: '${entry.points}',
                label: 'PUNTOS',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBox(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                value: '${entry.completed}',
                label: 'RETOS',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatBox(
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
                value: '$percent%',
                label: 'CUMPLIMIENTO',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBox(
                icon: Icons.emoji_events_rounded,
                color: AppColors.orange,
                value: '${entry.wins}',
                label: 'VICTORIAS',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.label),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.board, required this.state});

  final RankingBoard board;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = board.history;
    return CCCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _HistoryRow(entry: items[i], state: state),
            if (i != items.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.state});

  final HistoryEntry entry;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final winner = state.memberById(entry.winnerId);
    final iWon = entry.winnerId == state.user.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iWon ? AppColors.yellowSoft : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 22,
              color: iWon ? AppColors.yellow : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  iWon ? '¡Ganaste tú!' : 'Ganó ${winner?.firstName ?? 'otro integrante'}',
                  style: AppText.bodyMuted,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Tú: ${entry.userRank}.º', style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${entry.userPoints} pts', style: AppText.label),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gráfica de líneas (tú vs. promedio del bonche), dibujada en código.
class _EvolutionChartPainter extends CustomPainter {
  _EvolutionChartPainter({
    required this.labels,
    required this.userValues,
    required this.groupValues,
  });

  final List<String> labels;
  final List<double> userValues;
  final List<double> groupValues;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 8.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 26.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;
    if (chartW <= 0 || chartH <= 0 || labels.isEmpty) return;

    var maxValue = 1.0;
    for (final value in userValues) {
      if (value > maxValue) maxValue = value;
    }
    for (final value in groupValues) {
      if (value > maxValue) maxValue = value;
    }
    maxValue *= 1.15;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = topPad + chartH * i / 3;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );
    }

    double xAt(int i) => labels.length == 1
        ? leftPad + chartW / 2
        : leftPad + chartW * i / (labels.length - 1);
    double yAt(double v) => topPad + chartH * (1 - v / maxValue);

    void drawSeries(
      List<double> values,
      Color color,
      double strokeWidth,
      bool fill,
    ) {
      if (values.isEmpty) return;
      final count = values.length > labels.length ? labels.length : values.length;

      final path = Path()..moveTo(xAt(0), yAt(values[0]));
      for (var i = 1; i < count; i++) {
        path.lineTo(xAt(i), yAt(values[i]));
      }

      if (fill && count > 1) {
        final area = Path.from(path)
          ..lineTo(xAt(count - 1), topPad + chartH)
          ..lineTo(xAt(0), topPad + chartH)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..color = color.withValues(alpha: 0.12)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final dotPaint = Paint()..color = color;
      for (var i = 0; i < count; i++) {
        canvas.drawCircle(Offset(xAt(i), yAt(values[i])), strokeWidth + 1, dotPaint);
      }
    }

    drawSeries(groupValues, AppColors.textSecondary, 2, false);
    drawSeries(userValues, AppColors.yellow, 3.5, true);

    for (var i = 0; i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(xAt(i) - painter.width / 2, size.height - bottomPad + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EvolutionChartPainter oldDelegate) => true;
}