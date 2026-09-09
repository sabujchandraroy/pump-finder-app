import '../repositories/report_repository.dart';
import '../entities/report.dart';
class GetMyReports {
  final ReportRepository repository;
  const GetMyReports(this.repository);
  Future<List<Report>> call() => repository.getMyReports();
}
