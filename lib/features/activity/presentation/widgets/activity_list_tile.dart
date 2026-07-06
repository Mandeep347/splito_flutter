import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/activity_item.dart';
import 'activity_icon.dart';

/// List tile widget presenting a single activity item description and timestamp.
class ActivityListTile extends StatelessWidget {
  /// The activity item entity.
  final ActivityItem activity;

  /// Creates a new [ActivityListTile] instance.
  const ActivityListTile({
    required this.activity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: ActivityIcon(
              iconKey: activity.iconKey,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelativeDate(activity.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (activityDate == today) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (activityDate == yesterday) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('d MMM, h:mm a').format(dateTime);
    }
  }
}
