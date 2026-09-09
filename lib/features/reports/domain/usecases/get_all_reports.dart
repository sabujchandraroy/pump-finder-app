import '../repositories/report_repository.dart';
import '../entities/report.dart';
class GetAllReports {
  final ReportRepository repository;
  const GetAllReports(this.repository);
  Future<List<Report>> call() => repository.getAllReports();
}
