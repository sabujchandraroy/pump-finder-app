import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateMyProfile({required String displayName, required String phone});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;
  const ProfileRemoteDataSourceImpl(this.client);

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');
    return user.id;
  }

  String get _email => client.auth.currentUser?.email ?? '';

  @override
  Future<ProfileModel> getMyProfile() async {
    final row = await client.from('profiles').select().eq('id', _userId).maybeSingle();
    if (row == null) {
      throw StateError('Profile was not found. Please sign in again.');
    }
    final map = Map<String, dynamic>.from(row);
    map['email'] = _email;
    return ProfileModel.fromMap(map);
  }

  @override
  Future<ProfileModel> updateMyProfile({required String displayName, required String phone}) async {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('Display name is required.');
    if (name.length > 60) throw ArgumentError('Display name must be 60 characters or less.');
    if (phone.trim().length > 30) throw ArgumentError('Phone number is too long.');

    final row = await client
        .from('profiles')
        .update({'display_name': name, 'phone': phone.trim()})
        .eq('id', _userId)
        .select()
        .single();
    final map = Map<String, dynamic>.from(row);
    map['email'] = _email;
    return ProfileModel.fromMap(map);
  }
}
