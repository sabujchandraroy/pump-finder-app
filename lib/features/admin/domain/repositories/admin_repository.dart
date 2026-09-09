import '../entities/admin_dashboard_stats.dart';

import '../../../petrol_pump/domain/entities/petrol_pump.dart';

abstract class AdminRepository {
  Future<bool> isCurrentUserAdmin();
  Future<List<PetrolPump>> getAllPumps();
  Future<PetrolPump> createPump(Map<String, dynamic> data);
  Future<PetrolPump> updatePump(String id, Map<String, dynamic> data);
  Future<void> deletePump(String id);
  Future<AdminDashboardStats> getDashboardStats();
}
