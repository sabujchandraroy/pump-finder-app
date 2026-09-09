import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final model = await remoteDataSource.signIn(
      email: email,
      password: password,
    );
    return AuthUser(id: model.id, email: model.email);
  }

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
  }) async {
    final model = await remoteDataSource.signUp(
      email: email,
      password: password,
    );
    if (model == null) return null;
    return AuthUser(id: model.id, email: model.email);
  }

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  AuthUser? getCurrentUser() {
    final model = remoteDataSource.getCurrentUser();
    if (model == null) return null;
    return AuthUser(id: model.id, email: model.email);
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((model) {
      if (model == null) return null;
      return AuthUser(id: model.id, email: model.email);
    });
  }
}
