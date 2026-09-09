import 'package:flutter/foundation.dart';
import '../../../petrol_pump/domain/entities/petrol_pump.dart';
import '../../domain/usecases/is_current_user_admin.dart';
import '../../domain/usecases/get_admin_pumps.dart';
import '../../domain/usecases/create_pump.dart';
import '../../domain/usecases/update_pump.dart';
import '../../domain/usecases/delete_pump.dart';
import '../../domain/usecases/get_admin_dashboard_stats.dart';
import '../../domain/entities/admin_dashboard_stats.dart';

class AdminProvider extends ChangeNotifier {
  final IsCurrentUserAdmin isCurrentUserAdmin;
  final GetAdminPumps getAdminPumps;
  final CreatePump createPump;
  final UpdatePump updatePump;
  final DeletePump deletePump;
  final GetAdminDashboardStats getAdminDashboardStats;
  AdminProvider({required this.isCurrentUserAdmin,required this.getAdminPumps,required this.createPump,required this.updatePump,required this.deletePump,required this.getAdminDashboardStats});
  bool _isAdmin=false,_loading=false; String? _error; List<PetrolPump> _pumps=[]; AdminDashboardStats? _stats;
  bool get isAdmin=>_isAdmin; bool get isLoading=>_loading; String? get errorMessage=>_error; List<PetrolPump> get pumps=>List.unmodifiable(_pumps); AdminDashboardStats? get stats=>_stats;
  Future<void> checkAccess() async { _loading=true;_error=null;notifyListeners(); try{_isAdmin=await isCurrentUserAdmin();if(_isAdmin)_pumps=await getAdminPumps();}catch(e){_error=e.toString().replaceFirst('Exception: ','');}finally{_loading=false;notifyListeners();} }
  Future<void> loadDashboardStats() async {
    try {
      if (!_isAdmin) await checkAccess();
      if (!_isAdmin) return;
      _stats = await getAdminDashboardStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
  Future<void> loadPumps() async=>_run(()async{_pumps=await getAdminPumps();});
  Future<bool> add(Map<String,dynamic> data)=>_runBool(()async{final p=await createPump(data);_pumps=[..._pumps,p];});
  Future<bool> edit(String id,Map<String,dynamic> data)=>_runBool(()async{final p=await updatePump(id,data);_pumps=_pumps.map((x)=>x.id==id?p:x).toList();});
  Future<bool> remove(String id)=>_runBool(()async{await deletePump(id);_pumps=_pumps.where((x)=>x.id!=id).toList();});
  Future<void> _run(Future<void> Function() action)async{_loading=true;_error=null;notifyListeners();try{await action();}catch(e){_error=e.toString().replaceFirst('Exception: ','');}finally{_loading=false;notifyListeners();}}
  Future<bool> _runBool(Future<void> Function() action)async{await _run(action);return _error==null;}
}
