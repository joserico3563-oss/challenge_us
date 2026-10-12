import '../data/mock_data.dart';
import '../models/models.dart';

abstract class RankingService {
  Future<RankingBoard> fetchBoard(RankingPeriod period, DateTime now);
}

class MockRankingService implements RankingService {
  const MockRankingService();

  @override
  Future<RankingBoard> fetchBoard(RankingPeriod period, DateTime now) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.rankingBoard(period, now);
  }
}