import '../entities/pump_review.dart';

abstract class ReviewRepository {
  Future<List<PumpReview>> getReviews(String pumpId);
  Future<PumpReview> addReview({required String pumpId, required int rating, required String comment});
  Future<PumpReview> updateReview({required String reviewId, required int rating, required String comment});
  Future<void> deleteReview(String reviewId);
}
