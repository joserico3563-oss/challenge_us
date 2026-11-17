import '../data/mock_data.dart';
import '../models/models.dart';

abstract class ChallengeService {
  Future<List<Challenge>> fetchTodayChallenges(String boncheId);
}

class MockChallengeService implements ChallengeService {
  const MockChallengeService();

  @override
  Future<List<Challenge>> fetchTodayChallenges(String boncheId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return MockData.todayChallenges(DateTime.now());
  }
}