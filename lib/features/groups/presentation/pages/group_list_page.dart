import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/features/groups/domain/entities/group.dart';
import 'package:splito_flutter/features/groups/presentation/providers/group_providers.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/group_card.dart';
import 'package:splito_flutter/shared/widgets/async_value_widget.dart';
import 'package:splito_flutter/shared/widgets/empty_state_widget.dart';

/// Screen listing all groups the user belongs to.
class GroupListPage extends ConsumerWidget {
  /// Creates a const [GroupListPage] instance.
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(myGroupsProvider);

    // Listens to create group mutation to show status SnackBars
    ref.listen<AsyncValue<void>>(createGroupProvider, (previous, next) {
      if (next is AsyncData<void> && previous is AsyncLoading<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created!')),
        );
      } else if (next is AsyncError<void>) {
        final errorMessage =
            next.error is Failure ? (next.error as Failure).message : 'Failed to create group.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => CreateGroupSheet.show(context),
          ),
        ],
      ),
      body: AsyncValueWidget<List<Group>>(
        value: groupsAsync,
        data: (groups) {
          if (groups.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.group_outlined,
              title: 'No groups yet',
              subtitle: 'Create a group to start splitting expenses.',
              actionLabel: 'Create Group',
              onAction: () => CreateGroupSheet.show(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myGroupsProvider);
              try {
                await ref.read(myGroupsProvider.future);
              } catch (_) {}
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupCard(group: group);
              },
            ),
          );
        },
      ),
    );
  }
}
