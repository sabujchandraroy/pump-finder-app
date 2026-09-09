import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  const SignUp(this.repository);

  Future<AuthUser?> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}
