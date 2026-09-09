import '../../domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.reporterId,
    required super.reporterName,
    super.pumpId,
    super.pumpName,
    super.reviewId,
    required super.reason,
    required super.details,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    final pump = map['petrol_pumps'];
    return ReportModel(
      id: map['id'] as String,
      reporterId: map['reporter_id'] as String,
      reporterName: (map['reporter_name'] as String?)?.trim().isNotEmpty == true
          ? map['reporter_name'] as String
          : 'User',
      pumpId: map['pump_id'] as String?,
      pumpName: pump is Map ? pump['name'] as String? : null,
      reviewId: map['review_id'] as String?,
      reason: map['reason'] as String,
      details: (map['details'] as String?) ?? '',
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
