import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> signIn({required String email, required String password});
  Future<AuthUserModel?> signUp({required String email, required String password});
  Future<void> signOut();
  AuthUserModel? getCurrentUser();
  Stream<AuthUserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;
  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthUserModel> signIn({required String email, required String password}) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) throw StateError('Unable to sign in.');
    return AuthUserModel.fromSupabase(user);
  }

  @override
  Future<AuthUserModel?> signUp({required String email, required String password}) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    return user == null ? null : AuthUserModel.fromSupabase(user);
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  AuthUserModel? getCurrentUser() {
    final user = client.auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabase(user);
  }

  @override
  Stream<AuthUserModel?> get authStateChanges {
    return client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user == null ? null : AuthUserModel.fromSupabase(user);
    });
  }
}
