import '../entities/app_notification.dart';

/// Abstract contract governing notification operations.
abstract interface class INotificationRepository {
  /// Fetches all notifications for the authenticated user.
  Future<List<AppNotification>> getNotifications();

  /// Marks a specific notification as read.
  Future<AppNotification> markAsRead({required String notificationId});

  /// Marks all notifications as read for the authenticated user, returning updated count.
  Future<int> markAllAsRead();

  /// Gets the count of unread notifications.
  Future<int> getUnreadCount();
}
