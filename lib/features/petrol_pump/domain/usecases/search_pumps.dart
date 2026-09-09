import '../entities/petrol_pump.dart';
import '../repositories/petrol_pump_repository.dart';

class SearchPumps {
  final PetrolPumpRepository repository;

  const SearchPumps(this.repository);

  Future<List<PetrolPump>> call(String query) {
    return repository.searchPumps(query);
  }
}
