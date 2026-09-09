import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  const ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Profile> getMyProfile() => remoteDataSource.getMyProfile();

  @override
  Future<Profile> updateMyProfile({required String displayName, required String phone}) =>
      remoteDataSource.updateMyProfile(displayName: displayName, phone: phone);
}
