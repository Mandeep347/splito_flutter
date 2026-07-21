import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/features/activity/domain/entities/activity_item.dart';
import 'package:splito_flutter/features/activity/presentation/providers/activity_providers.dart';
import 'package:splito_flutter/features/activity/presentation/widgets/activity_list_tile.dart';
import 'package:splito_flutter/shared/widgets/async_value_widget.dart';
import 'package:splito_flutter/shared/widgets/empty_state_widget.dart';

class GlobalActivityPage extends ConsumerWidget {
  const GlobalActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(globalActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(globalActivityProvider);
            },
          ),
        ],
      ),
      body: AsyncValueWidget<List<ActivityItem>>(
        value: activityAsync,
        data: (activities) {
          if (activities.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'No activity yet',
              subtitle: 'Transactions and group changes will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(globalActivityProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityListTile(activity: activity);
              },
            ),
          );
        },
      ),
    );
  }
}
