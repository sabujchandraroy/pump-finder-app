import '../repositories/petrol_pump_repository.dart';

class GetFavoritePumps {
  final PetrolPumpRepository repository;
  const GetFavoritePumps(this.repository);

  Future<Set<String>> call() => repository.getFavoriteIds();
}
