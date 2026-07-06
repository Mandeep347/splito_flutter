/// Represents an in-app notification.
class AppNotification {
  /// The unique identifier of the notification.
  final String id;

  /// The type of notification (e.g. 'EXPENSE_ADDED', 'GROUP_DELETED').
  final String type;

  /// The title of the notification message (nullable).
  final String? title;

  /// The descriptive message body of the notification (nullable).
  final String? message;

  /// Whether the notification has been marked as read by the user.
  final bool isRead;

  /// Optional arbitrary metadata payload associated with the notification.
  final Map<String, dynamic>? metadata;

  /// The date and time when the notification was created.
  final DateTime createdAt;

  /// Creates a new [AppNotification] instance.
  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.message,
    required this.isRead,
    this.metadata,
    required this.createdAt,
  });

  /// Returns true if the notification is unread.
  bool get isUnread => !isRead;

  /// The display title fallback logic.
  String get displayTitle => title ?? type;

  /// The display message fallback logic.
  String get displayMessage => message ?? '';
}
