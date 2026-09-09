import '../../../petrol_pump/domain/entities/petrol_pump.dart';
import '../repositories/admin_repository.dart';
class CreatePump { final AdminRepository repository; const CreatePump(this.repository); Future<PetrolPump> call(Map<String,dynamic> data)=>repository.createPump(data); }
