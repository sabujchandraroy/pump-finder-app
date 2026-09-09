import '../entities/pump_review.dart';
import '../repositories/review_repository.dart';

class GetPumpReviews {
  final ReviewRepository repository;
  const GetPumpReviews(this.repository);
  Future<List<PumpReview>> call(String pumpId) => repository.getReviews(pumpId);
}
