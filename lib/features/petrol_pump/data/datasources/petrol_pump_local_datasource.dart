import 'package:hive_flutter/hive_flutter.dart';

import '../models/petrol_pump_model.dart';

abstract class PetrolPumpLocalDataSource {
  Future<List<PetrolPumpModel>> getCachedPumps();
  Future<void> cachePumps(List<PetrolPumpModel> pumps);
  Future<Set<String>> getFavoriteIds();
  Future<void> saveFavoriteIds(Set<String> ids);
}

class PetrolPumpLocalDataSourceImpl implements PetrolPumpLocalDataSource {
  static const String pumpsBoxName = 'petrol_pumps_cache';
  static const String favoritesBoxName = 'petrol_pump_favorites';

  Box<PetrolPumpModel> get _pumpsBox => Hive.box<PetrolPumpModel>(pumpsBoxName);
  Box<bool> get _favoritesBox => Hive.box<bool>(favoritesBoxName);

  @override
  Future<List<PetrolPumpModel>> getCachedPumps() async {
    return List.unmodifiable(_pumpsBox.values.toList());
  }

  @override
  Future<void> cachePumps(List<PetrolPumpModel> pumps) async {
    await _pumpsBox.clear();

    final entries = <String, PetrolPumpModel>{
      for (final pump in pumps) pump.id: pump,
    };

    if (entries.isNotEmpty) {
      await _pumpsBox.putAll(entries);
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return _favoritesBox.keys.whereType<String>().toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    await _favoritesBox.clear();

    if (ids.isEmpty) return;

    await _favoritesBox.putAll({
      for (final id in ids) id: true,
    });
  }
}
