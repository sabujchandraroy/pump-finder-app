import 'package:flutter/foundation.dart';

import '../../domain/entities/pump_review.dart';
import '../../domain/usecases/add_pump_review.dart';
import '../../domain/usecases/delete_pump_review.dart';
import '../../domain/usecases/get_pump_reviews.dart';
import '../../domain/usecases/update_pump_review.dart';

class ReviewProvider extends ChangeNotifier {
  final GetPumpReviews getPumpReviews;
  final AddPumpReview addPumpReview;
  final UpdatePumpReview updatePumpReview;
  final DeletePumpReview deletePumpReview;

  ReviewProvider({
    required this.getPumpReviews,
    required this.addPumpReview,
    required this.updatePumpReview,
    required this.deletePumpReview,
  });

  List<PumpReview> _reviews = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _pumpId;

  List<PumpReview> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  PumpReview? get myReview {
    for (final review in _reviews) {
      // The UI compares this against the signed-in user separately.
      if (review.userId.isNotEmpty) return review;
    }
    return null;
  }

  Future<void> loadReviews(String pumpId) async {
    _pumpId = pumpId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await getPumpReviews(pumpId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> add({required int rating, required String comment}) async {
    if (_pumpId == null) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final review = await addPumpReview(pumpId: _pumpId!, rating: rating, comment: comment);
      _reviews = [review, ..._reviews];
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> edit({required String reviewId, required int rating, required String comment}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await updatePumpReview(reviewId: reviewId, rating: rating, comment: comment);
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        _reviews[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> remove(String reviewId) async {
    _errorMessage = null;
    try {
      await deletePumpReview(reviewId);
      _reviews.removeWhere((review) => review.id == reviewId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
