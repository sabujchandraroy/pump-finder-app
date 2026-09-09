class PumpReview {
  final String id;
  final String pumpId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PumpReview({
    required this.id,
    required this.pumpId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasComment => comment.trim().isNotEmpty;
}
