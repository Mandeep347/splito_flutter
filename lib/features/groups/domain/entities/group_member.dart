/// Represents a member within a Splito group.
class GroupMember {
  /// The unique identifier of the user.
  final String userId;

  /// The full name of the user.
  final String name;

  /// The email address of the user.
  final String email;

  /// The role of the user inside the group (e.g. 'ADMIN', 'MEMBER').
  final String role;

  /// The membership status of the user (e.g. 'ACTIVE', 'INVITED').
  final String status;

  /// The date and time when the member joined the group.
  final DateTime joinedAt;

  /// Creates a new [GroupMember] instance.
  const GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  /// Check if the member has administrative rights.
  bool get isAdmin => role == 'ADMIN';

  /// Check if the member is active.
  bool get isActive => status == 'ACTIVE';

  /// Extracts the initials of the member from their name.
  /// Uses first letter of the first and last word in name, uppercased.
  /// If it is a single word, uses the first letter only.
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
