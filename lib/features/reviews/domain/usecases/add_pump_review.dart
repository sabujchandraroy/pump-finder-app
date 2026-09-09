import '../entities/pump_review.dart';
import '../repositories/review_repository.dart';

class AddPumpReview {
  final ReviewRepository repository;
  const AddPumpReview(this.repository);
  Future<PumpReview> call({required String pumpId, required int rating, required String comment}) =>
      repository.addReview(pumpId: pumpId, rating: rating, comment: comment);
}
