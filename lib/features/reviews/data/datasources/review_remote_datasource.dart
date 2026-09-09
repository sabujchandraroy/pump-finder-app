import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pump_review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<PumpReviewModel>> getReviews(String pumpId);
  Future<PumpReviewModel> addReview({required String pumpId, required int rating, required String comment});
  Future<PumpReviewModel> updateReview({required String reviewId, required int rating, required String comment});
  Future<void> deleteReview(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient client;
  const ReviewRemoteDataSourceImpl(this.client);

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('You must be signed in to review a pump.');
    return user.id;
  }

  Future<String> _currentUserName() async {
    final profile = await client
        .from('profiles')
        .select('display_name')
        .eq('id', _userId)
        .maybeSingle();
    final name = (profile?['display_name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    return client.auth.currentUser?.email?.split('@').first ?? 'User';
  }

  @override
  Future<List<PumpReviewModel>> getReviews(String pumpId) async {
    final rows = await client
        .from('pump_reviews')
        .select()
        .eq('pump_id', pumpId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => PumpReviewModel.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  void _validate(int rating, String comment) {
    if (rating < 1 || rating > 5) throw ArgumentError('Rating must be between 1 and 5.');
    if (comment.trim().length > 500) throw ArgumentError('Review must be 500 characters or less.');
  }

  @override
  Future<PumpReviewModel> addReview({required String pumpId, required int rating, required String comment}) async {
    _validate(rating, comment);
    final existing = await client
        .from('pump_reviews')
        .select('id')
        .eq('pump_id', pumpId)
        .eq('user_id', _userId)
        .maybeSingle();
    if (existing != null) throw StateError('You have already reviewed this pump.');

    final row = await client.from('pump_reviews').insert({
      'pump_id': pumpId,
      'user_id': _userId,
      'user_name': await _currentUserName(),
      'rating': rating,
      'comment': comment.trim(),
    }).select().single();
    return PumpReviewModel.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<PumpReviewModel> updateReview({required String reviewId, required int rating, required String comment}) async {
    _validate(rating, comment);
    final row = await client
        .from('pump_reviews')
        .update({'rating': rating, 'comment': comment.trim()})
        .eq('id', reviewId)
        .eq('user_id', _userId)
        .select()
        .single();
    return PumpReviewModel.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await client.from('pump_reviews').delete().eq('id', reviewId).eq('user_id', _userId);
  }
}
