import '../../domain/entities/pump_review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  const ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PumpReview>> getReviews(String pumpId) => remoteDataSource.getReviews(pumpId);

  @override
  Future<PumpReview> addReview({required String pumpId, required int rating, required String comment}) =>
      remoteDataSource.addReview(pumpId: pumpId, rating: rating, comment: comment);

  @override
  Future<PumpReview> updateReview({required String reviewId, required int rating, required String comment}) =>
      remoteDataSource.updateReview(reviewId: reviewId, rating: rating, comment: comment);

  @override
  Future<void> deleteReview(String reviewId) => remoteDataSource.deleteReview(reviewId);
}
