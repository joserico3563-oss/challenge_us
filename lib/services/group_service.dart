import '../data/mock_data.dart';
import '../models/models.dart';

/// Grupo privado (Bonche).
abstract class GroupService {
  /// Bonche del usuario, o null si todavia no esta en ninguno.
  Future<GroupInfo?> fetchGroup(String userId);

  Future<void> createGroup({
    required String name,
    required String description,
    required String leaderId,
  });

  Future<void> joinGroup({
    required String inviteCode,
    required String userId,
  });
}

class MockGroupService implements GroupService {
  const MockGroupService();

  @override
  Future<GroupInfo?> fetchGroup(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return MockData.group(DateTime.now());
  }

  @override
  Future<void> createGroup({
    required String name,
    required String description,
    required String leaderId,
  }) {
    throw UnsupportedError('El servicio mock no crea bonches.');
  }

  @override
  Future<void> joinGroup({
    required String inviteCode,
    required String userId,
  }) {
    throw UnsupportedError('El servicio mock no une a bonches.');
  }
}