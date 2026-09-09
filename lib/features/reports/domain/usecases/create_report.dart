import '../repositories/report_repository.dart';
import '../entities/report.dart';

class CreateReport {
  final ReportRepository repository;
  const CreateReport(this.repository);
  Future<Report> call({String? pumpId, String? reviewId, required String reason, required String details}) =>
      repository.createReport(pumpId: pumpId, reviewId: reviewId, reason: reason, details: details);
}
