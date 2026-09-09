import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfile {
  final ProfileRepository repository;
  const UpdateMyProfile(this.repository);

  Future<Profile> call({required String displayName, required String phone}) =>
      repository.updateMyProfile(displayName: displayName, phone: phone);
}
