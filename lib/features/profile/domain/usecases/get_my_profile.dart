import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetMyProfile {
  final ProfileRepository repository;
  const GetMyProfile(this.repository);

  Future<Profile> call() => repository.getMyProfile();
}
