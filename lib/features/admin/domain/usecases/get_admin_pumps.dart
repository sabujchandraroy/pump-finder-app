import '../../../petrol_pump/domain/entities/petrol_pump.dart';
import '../repositories/admin_repository.dart';
class GetAdminPumps { final AdminRepository repository; const GetAdminPumps(this.repository); Future<List<PetrolPump>> call()=>repository.getAllPumps(); }
