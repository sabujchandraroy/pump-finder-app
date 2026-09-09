import '../repositories/admin_repository.dart';
class DeletePump { final AdminRepository repository; const DeletePump(this.repository); Future<void> call(String id)=>repository.deletePump(id); }
