import '../entities/petrol_pump.dart';
import '../repositories/petrol_pump_repository.dart';

class GetPetrolPumps {
  final PetrolPumpRepository repository;

  const GetPetrolPumps(this.repository);

  Future<List<PetrolPump>> call() {
    return repository.getPetrolPumps();
  }
}
