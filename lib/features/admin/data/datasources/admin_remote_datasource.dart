import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../petrol_pump/data/models/petrol_pump_model.dart';
import '../../domain/entities/admin_dashboard_stats.dart';

abstract class AdminRemoteDataSource {
  Future<bool> isCurrentUserAdmin();
  Future<List<PetrolPumpModel>> getAllPumps();
  Future<PetrolPumpModel> createPump(Map<String, dynamic> data);
  Future<PetrolPumpModel> updatePump(String id, Map<String, dynamic> data);
  Future<void> deletePump(String id);
  Future<AdminDashboardStats> getDashboardStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient client;
  const AdminRemoteDataSourceImpl(this.client);

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');
    return user.id;
  }

  @override
  Future<bool> isCurrentUserAdmin() async {
    final row = await client.from('profiles').select('role').eq('id', _userId).maybeSingle();
    return row?['role'] == 'admin';
  }

  @override
  Future<List<PetrolPumpModel>> getAllPumps() async {
    final data = await client.from('petrol_pumps').select().order('name');
    return data.map((row) => PetrolPumpModel.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  void _validate(Map<String, dynamic> data) {
    final name = data['name']?.toString().trim() ?? '';
    final address = data['address']?.toString().trim() ?? '';
    final lat = data['latitude'];
    final lng = data['longitude'];
    if (name.isEmpty || address.isEmpty) throw ArgumentError('Name and address are required.');
    if (lat is! num || lng is! num || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError('Enter valid latitude and longitude.');
    }
  }

  @override
  Future<PetrolPumpModel> createPump(Map<String, dynamic> data) async {
    _validate(data);
    final row = await client.from('petrol_pumps').insert(data).select().single();
    return PetrolPumpModel.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<PetrolPumpModel> updatePump(String id, Map<String, dynamic> data) async {
    _validate(data);
    final row = await client.from('petrol_pumps').update(data).eq('id', id).select().single();
    return PetrolPumpModel.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> deletePump(String id) async {
    await client.from('petrol_pumps').delete().eq('id', id);
  }

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final pumps = await getAllPumps();
    final open = pumps.where((pump) => pump.isOpen).length;
    final rated = pumps.where((pump) => pump.rating > 0).length;
    return AdminDashboardStats(
      totalPumps: pumps.length,
      openPumps: open,
      closedPumps: pumps.length - open,
      ratedPumps: rated,
    );
  }
}
