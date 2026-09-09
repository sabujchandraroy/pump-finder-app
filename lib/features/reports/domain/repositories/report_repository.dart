import '../entities/report.dart';

abstract class ReportRepository {
  Future<Report> createReport({String? pumpId, String? reviewId, required String reason, required String details});
  Future<List<Report>> getMyReports();
  Future<List<Report>> getAllReports();
  Future<void> updateReportStatus(String reportId, String status);
}
