import '../entities/petrol_pump.dart';
import '../repositories/petrol_pump_repository.dart';

class GetNearbyPumps {
  final PetrolPumpRepository repository;

  const GetNearbyPumps(this.repository);

  Future<List<PetrolPump>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) {
    return repository.getNearbyPumps(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
