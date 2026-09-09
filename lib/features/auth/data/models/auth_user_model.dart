import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.id, required super.email});

  factory AuthUserModel.fromSupabase(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }
}
