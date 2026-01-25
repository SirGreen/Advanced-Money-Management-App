class InMemoryService {
  int _storage = 0;

  Future<int> read() async {
    return _storage;
  }

  Future<void> write(int amount) async {
    _storage = amount;
  }
}
