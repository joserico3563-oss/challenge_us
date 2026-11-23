import '../data/mock_data.dart';
import '../models/models.dart';

abstract class RankingService {
  /// Ranking del bonche indicado, o null si no hay datos.
  Future<RankingBoard?> fetchBoard(
    RankingPeriod period,
    DateTime now, {
    String boncheId = '',
  });
}

class MockRankingService implements RankingService {
  const MockRankingService();

  @override
  Future<RankingBoard> fetchBoard(
    RankingPeriod period,
    DateTime now, {
    String boncheId = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.rankingBoard(period, now);
  }
}