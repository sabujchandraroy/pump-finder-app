import '../../../petrol_pump/domain/entities/petrol_pump.dart';
import '../repositories/admin_repository.dart';
class UpdatePump { final AdminRepository repository; const UpdatePump(this.repository); Future<PetrolPump> call(String id,Map<String,dynamic> data)=>repository.updatePump(id,data); }
