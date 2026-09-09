import '../../domain/entities/pump_review.dart';

class PumpReviewModel extends PumpReview {
  const PumpReviewModel({
    required super.id,
    required super.pumpId,
    required super.userId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PumpReviewModel.fromMap(Map<String, dynamic> map) {
    return PumpReviewModel(
      id: map['id'] as String,
      pumpId: map['pump_id'] as String,
      userId: map['user_id'] as String,
      userName: (map['user_name'] as String?)?.trim().isNotEmpty == true
          ? map['user_name'] as String
          : 'Anonymous',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: (map['comment'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }
}
