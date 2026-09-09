import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile();
  Future<Profile> updateMyProfile({required String displayName, required String phone});
}
