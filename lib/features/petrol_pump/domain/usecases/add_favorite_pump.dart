import '../repositories/petrol_pump_repository.dart';

class AddFavoritePump {
  final PetrolPumpRepository repository;

  const AddFavoritePump(this.repository);

  Future<void> call(String pumpId) {
    return repository.addFavoritePump(pumpId);
  }
}
