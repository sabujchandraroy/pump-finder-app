import '../repositories/admin_repository.dart';
class IsCurrentUserAdmin { final AdminRepository repository; const IsCurrentUserAdmin(this.repository); Future<bool> call()=>repository.isCurrentUserAdmin(); }
