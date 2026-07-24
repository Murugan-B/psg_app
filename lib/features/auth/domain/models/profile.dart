class Profile {
  final String id;
  final String role;
  final bool isApproved;

  const Profile({
    required this.id,
    required this.role,
    this.isApproved = true,
  });

  bool get isAdmin => role == 'admin' || role == 'attendance_admin';
}
