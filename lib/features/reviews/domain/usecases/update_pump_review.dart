import '../entities/pump_review.dart';
import '../repositories/review_repository.dart';

class UpdatePumpReview {
  final ReviewRepository repository;
  const UpdatePumpReview(this.repository);
  Future<PumpReview> call({required String reviewId, required int rating, required String comment}) =>
      repository.updateReview(reviewId: reviewId, rating: rating, comment: comment);
}
