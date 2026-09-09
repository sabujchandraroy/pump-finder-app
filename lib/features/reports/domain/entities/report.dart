class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? pumpId;
  final String? pumpName;
  final String? reviewId;
  final String reason;
  final String details;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.pumpId,
    this.pumpName,
    this.reviewId,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == 'open';
}
