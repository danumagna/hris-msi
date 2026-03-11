/// Represents an authenticated user in the domain layer.
///
/// This entity is framework-agnostic and contains only
/// the business-relevant properties of a user.
class User {
  final String id;
  final String employeeId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String role;

  const User({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });
}
