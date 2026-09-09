import '../entities/admin_dashboard_stats.dart';
import '../repositories/admin_repository.dart';

class GetAdminDashboardStats {
  final AdminRepository repository;
  const GetAdminDashboardStats(this.repository);

  Future<AdminDashboardStats> call() => repository.getDashboardStats();
}
