import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  const SignIn(this.repository);

  Future<AuthUser> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
