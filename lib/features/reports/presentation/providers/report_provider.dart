import 'package:flutter/foundation.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/create_report.dart';
import '../../domain/usecases/get_all_reports.dart';
import '../../domain/usecases/get_my_reports.dart';
import '../../domain/usecases/update_report_status.dart';

class ReportProvider extends ChangeNotifier {
  final CreateReport createReport;
  final GetMyReports getMyReports;
  final GetAllReports getAllReports;
  final UpdateReportStatus updateReportStatus;
  ReportProvider({required this.createReport, required this.getMyReports, required this.getAllReports, required this.updateReportStatus});

  List<Report> _reports = [];
  bool _loading = false;
  bool _saving = false;
  String? _error;
  List<Report> get reports => List.unmodifiable(_reports);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  Future<void> loadMine() async {
    _loading = true; _error = null; notifyListeners();
    try { _reports = await getMyReports(); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }

  Future<void> loadAll() async {
    _loading = true; _error = null; notifyListeners();
    try { _reports = await getAllReports(); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }

  Future<bool> submit({String? pumpId, String? reviewId, required String reason, required String details}) async {
    _saving = true; _error = null; notifyListeners();
    try { await createReport(pumpId: pumpId, reviewId: reviewId, reason: reason, details: details); _saving = false; notifyListeners(); return true; }
    catch (e) { _error = e.toString(); _saving = false; notifyListeners(); return false; }
  }

  Future<bool> setStatus(String id, String status) async {
    try { await updateReportStatus(id, status); final index = _reports.indexWhere((r) => r.id == id); if (index >= 0) await loadAll(); return true; }
    catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }
}
