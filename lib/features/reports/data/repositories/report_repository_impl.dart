import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  const ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Report> createReport({String? pumpId, String? reviewId, required String reason, required String details}) =>
      remoteDataSource.createReport(pumpId: pumpId, reviewId: reviewId, reason: reason, details: details);

  @override
  Future<List<Report>> getMyReports() => remoteDataSource.getMyReports();

  @override
  Future<List<Report>> getAllReports() => remoteDataSource.getAllReports();

  @override
  Future<void> updateReportStatus(String reportId, String status) => remoteDataSource.updateReportStatus(reportId, status);
}
