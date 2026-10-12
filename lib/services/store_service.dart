import '../data/mock_data.dart';
import '../models/models.dart';

abstract class StoreService {
  Future<List<StoreItem>> fetchItems();
}

class MockStoreService implements StoreService {
  const MockStoreService();

  @override
  Future<List<StoreItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.storeItems();
  }
}