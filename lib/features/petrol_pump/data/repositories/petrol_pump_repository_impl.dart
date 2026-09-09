import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/petrol_pump.dart';
import '../../domain/repositories/petrol_pump_repository.dart';
import '../datasources/petrol_pump_local_datasource.dart';
import '../datasources/petrol_pump_remote_datasource.dart';

class PetrolPumpRepositoryImpl implements PetrolPumpRepository {
  final PetrolPumpRemoteDataSource remoteDataSource;
  final PetrolPumpLocalDataSource localDataSource;
  const PetrolPumpRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<List<PetrolPump>> getPetrolPumps() async {
    try {
      final pumps = await remoteDataSource.getPetrolPumps();
      await localDataSource.cachePumps(pumps);
      return _applyFavorites(pumps);
    } catch (_) {
      final cached = await localDataSource.getCachedPumps();
      if (cached.isEmpty) rethrow;
      return _applyFavorites(cached);
    }
  }

  @override
  Future<List<PetrolPump>> getNearbyPumps({required double latitude, required double longitude, double radiusKm = 10}) async {
    final pumps = await getPetrolPumps();
    return pumps.map((pump) => pump.copyWith(distanceKm: AppUtils.distanceInKm(latitude1: latitude, longitude1: longitude, latitude2: pump.latitude, longitude2: pump.longitude)))
      .where((pump) => pump.distanceKm <= radiusKm).toList()
      ..sort((a,b) => a.distanceKm.compareTo(b.distanceKm));
  }

  @override
  Future<List<PetrolPump>> searchPumps(String query) async {
    try {
      final pumps = await remoteDataSource.searchPumps(query);
      await localDataSource.cachePumps(pumps);
      return _applyFavorites(pumps);
    } catch (_) {
      final cached = await localDataSource.getCachedPumps();
      return _applyFavorites(cached.where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || p.address.toLowerCase().contains(query.toLowerCase())).toList());
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    try {
      final ids = await remoteDataSource.getFavoriteIds();
      await localDataSource.saveFavoriteIds(ids);
      return ids;
    } catch (_) {
      return localDataSource.getFavoriteIds();
    }
  }

  @override
  Future<void> addFavoritePump(String pumpId) async {
    final ids = Set<String>.from(await localDataSource.getFavoriteIds());
    ids.add(pumpId);
    await localDataSource.saveFavoriteIds(ids);
    try { await remoteDataSource.addFavoritePump(pumpId); } catch (_) {}
  }

  @override
  Future<void> removeFavoritePump(String pumpId) async {
    final ids = Set<String>.from(await localDataSource.getFavoriteIds());
    ids.remove(pumpId);
    await localDataSource.saveFavoriteIds(ids);
    try { await remoteDataSource.removeFavoritePump(pumpId); } catch (_) {}
  }

  Future<List<PetrolPump>> _applyFavorites(List<PetrolPump> pumps) async {
    final ids = await localDataSource.getFavoriteIds();
    return pumps.map((p) => p.copyWith(isFavorite: ids.contains(p.id))).toList();
  }
}
