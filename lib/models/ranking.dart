enum RankingPeriod { weekly, monthly }

class RankingEntry {
  const RankingEntry({
    required this.memberId,
    required this.points,
    required this.completed,
    required this.wins,
    required this.previousRank,
  });

  final String memberId;
  final int points;
  final int completed;
  final int wins;
  final int previousRank;

  RankingEntry copyWith({int? points, int? completed}) {
    return RankingEntry(
      memberId: memberId,
      points: points ?? this.points,
      completed: completed ?? this.completed,
      wins: wins,
      previousRank: previousRank,
    );
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.label,
    required this.winnerId,
    required this.userRank,
    required this.userPoints,
  });

  final String label;
  final String winnerId;
  final int userRank;
  final int userPoints;
}

class RankingBoard {
  const RankingBoard({
    required this.period,
    required this.periodLabel,
    required this.resetLabel,
    required this.entries,
    required this.totalChallenges,
    required this.chartLabels,
    required this.userSeries,
    required this.groupSeries,
    required this.history,
  });

  final RankingPeriod period;
  final String periodLabel;
  final String resetLabel;
  final List<RankingEntry> entries;
  final int totalChallenges;
  final List<String> chartLabels;
  final List<double> userSeries;
  final List<double> groupSeries;
  final List<HistoryEntry> history;
}