import '../data/mock_data.dart';
import '../models/models.dart';

/// Grupo privado (Bonche). Un backend real lo reemplazará más adelante.
abstract class GroupService {
  Future<GroupInfo> fetchGroup();
}

class MockGroupService implements GroupService {
  const MockGroupService();

  @override
  Future<GroupInfo> fetchGroup() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return MockData.group(DateTime.now());
  }
}