import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser?> signUp({required String email, required String password});
  Future<void> signOut();
  AuthUser? getCurrentUser();
  Stream<AuthUser?> get authStateChanges;
}
