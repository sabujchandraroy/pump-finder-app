import '../repositories/review_repository.dart';

class DeletePumpReview {
  final ReviewRepository repository;
  const DeletePumpReview(this.repository);
  Future<void> call(String reviewId) => repository.deleteReview(reviewId);
}
