import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/petrol_pump_model.dart';

abstract class PetrolPumpRemoteDataSource {
  Future<List<PetrolPumpModel>> getPetrolPumps();
  Future<List<PetrolPumpModel>> getNearbyPumps({required double latitude, required double longitude, double radiusKm = 10});
  Future<List<PetrolPumpModel>> searchPumps(String query);
  Future<Set<String>> getFavoriteIds();
  Future<void> addFavoritePump(String pumpId);
  Future<void> removeFavoritePump(String pumpId);
}

class PetrolPumpRemoteDataSourceImpl implements PetrolPumpRemoteDataSource {
  final SupabaseClient client;
  const PetrolPumpRemoteDataSourceImpl(this.client);

  @override
  Future<List<PetrolPumpModel>> getPetrolPumps() async {
    final data = await client.from('petrol_pumps').select().order('name', ascending: true);
    return data.map((row) => PetrolPumpModel.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  @override
  Future<List<PetrolPumpModel>> getNearbyPumps({required double latitude, required double longitude, double radiusKm = 10}) async => getPetrolPumps();

  @override
  Future<List<PetrolPumpModel>> searchPumps(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return getPetrolPumps();
    final data = await client.from('petrol_pumps').select().or('name.ilike.%$normalized%,address.ilike.%$normalized%').order('name', ascending: true);
    return data.map((row) => PetrolPumpModel.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('Please sign in to sync favorites.');
    return user.id;
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('No authenticated user.');
    final data = await client.from('favorite_petrol_pumps').select('pump_id').eq('user_id', user.id);
    return data.map((row) => row['pump_id'].toString()).toSet();
  }

  @override
  Future<void> addFavoritePump(String pumpId) async {
    await client.from('favorite_petrol_pumps').upsert({'user_id': _userId, 'pump_id': pumpId}, onConflict: 'user_id,pump_id');
  }

  @override
  Future<void> removeFavoritePump(String pumpId) async {
    await client.from('favorite_petrol_pumps').delete().eq('user_id', _userId).eq('pump_id', pumpId);
  }
}
