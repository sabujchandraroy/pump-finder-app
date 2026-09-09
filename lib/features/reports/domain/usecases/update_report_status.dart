import '../repositories/report_repository.dart';
class UpdateReportStatus {
  final ReportRepository repository;
  const UpdateReportStatus(this.repository);
  Future<void> call(String reportId, String status) => repository.updateReportStatus(reportId, status);
}
