import '../entities/petrol_pump.dart';

abstract class PetrolPumpRepository {
  Future<List<PetrolPump>> getPetrolPumps();
  Future<List<PetrolPump>> getNearbyPumps({required double latitude, required double longitude, double radiusKm = 10});
  Future<List<PetrolPump>> searchPumps(String query);
  Future<Set<String>> getFavoriteIds();
  Future<void> addFavoritePump(String pumpId);
  Future<void> removeFavoritePump(String pumpId);
}
