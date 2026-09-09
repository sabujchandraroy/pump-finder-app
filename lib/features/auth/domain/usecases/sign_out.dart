import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  const SignOut(this.repository);

  Future<void> call() => repository.signOut();
}
