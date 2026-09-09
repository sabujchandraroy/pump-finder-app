import '../repositories/petrol_pump_repository.dart';

class RemoveFavoritePump {
  final PetrolPumpRepository repository;
  const RemoveFavoritePump(this.repository);

  Future<void> call(String pumpId) => repository.removeFavoritePump(pumpId);
}
