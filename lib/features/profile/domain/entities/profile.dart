class Profile {
  final String id;
  final String email;
  final String displayName;
  final String phone;
  final String role;

  const Profile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.phone,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}
