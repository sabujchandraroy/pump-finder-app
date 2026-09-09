class StorageService {
  final Set<String> _favoriteIds = <String>{};

  Future<void> addFavorite(String pumpId) async {
    _favoriteIds.add(pumpId);
  }

  Future<void> removeFavorite(String pumpId) async {
    _favoriteIds.remove(pumpId);
  }

  Future<Set<String>> getFavoriteIds() async {
    return Set.unmodifiable(_favoriteIds);
  }
}
