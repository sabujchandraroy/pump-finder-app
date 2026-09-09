import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> createReport({String? pumpId, String? reviewId, required String reason, required String details});
  Future<List<ReportModel>> getMyReports();
  Future<List<ReportModel>> getAllReports();
  Future<void> updateReportStatus(String reportId, String status);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient client;
  const ReportRemoteDataSourceImpl(this.client);

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('You must be signed in to submit a report.');
    return user.id;
  }

  Future<String> _userName() async {
    final row = await client.from('profiles').select('display_name').eq('id', _userId).maybeSingle();
    final name = (row?['display_name'] as String?)?.trim();
    return name?.isNotEmpty == true ? name! : (client.auth.currentUser?.email?.split('@').first ?? 'User');
  }

  @override
  Future<ReportModel> createReport({String? pumpId, String? reviewId, required String reason, required String details}) async {
    if ((pumpId == null || pumpId.isEmpty) && (reviewId == null || reviewId.isEmpty)) {
      throw ArgumentError('A pump or review is required.');
    }
    if (reason.trim().isEmpty) throw ArgumentError('Please select a reason.');
    if (details.trim().length > 1000) throw ArgumentError('Details must be 1000 characters or less.');
    final row = await client.from('reports').insert({
      'reporter_id': _userId,
      'reporter_name': await _userName(),
      'pump_id': pumpId,
      'review_id': reviewId,
      'reason': reason.trim(),
      'details': details.trim(),
    }).select('*, petrol_pumps(name)').single();
    return ReportModel.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    final rows = await client.from('reports').select('*, petrol_pumps(name)').eq('reporter_id', _userId).order('created_at', ascending: false);
    return (rows as List).map((r) => ReportModel.fromMap(Map<String, dynamic>.from(r))).toList();
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    final rows = await client.from('reports').select('*, petrol_pumps(name)').order('created_at', ascending: false);
    return (rows as List).map((r) => ReportModel.fromMap(Map<String, dynamic>.from(r))).toList();
  }

  @override
  Future<void> updateReportStatus(String reportId, String status) async {
    const allowed = {'open', 'reviewing', 'resolved', 'dismissed'};
    if (!allowed.contains(status)) throw ArgumentError('Invalid report status.');
    await client.from('reports').update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', reportId);
  }
}
