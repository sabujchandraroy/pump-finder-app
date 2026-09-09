import '../../../petrol_pump/domain/entities/petrol_pump.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/admin_dashboard_stats.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  const AdminRepositoryImpl({required this.remoteDataSource});

  @override Future<bool> isCurrentUserAdmin() => remoteDataSource.isCurrentUserAdmin();
  @override Future<List<PetrolPump>> getAllPumps() => remoteDataSource.getAllPumps();
  @override Future<PetrolPump> createPump(Map<String,dynamic> data) => remoteDataSource.createPump(data);
  @override Future<PetrolPump> updatePump(String id, Map<String,dynamic> data) => remoteDataSource.updatePump(id, data);
  @override Future<void> deletePump(String id) => remoteDataSource.deletePump(id);
  @override Future<AdminDashboardStats> getDashboardStats() => remoteDataSource.getDashboardStats();
}
