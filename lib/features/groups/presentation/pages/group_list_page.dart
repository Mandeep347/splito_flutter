import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/features/groups/domain/entities/group.dart';
import 'package:splito_flutter/features/groups/presentation/providers/group_providers.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/group_card.dart';
import 'package:splito_flutter/shared/widgets/async_value_widget.dart';
import 'package:splito_flutter/shared/widgets/empty_state_widget.dart';
import 'package:splito_flutter/shared/widgets/overall_balance_card.dart';
import 'package:splito_flutter/features/balances/presentation/providers/balance_providers.dart';
import 'package:splito_flutter/shared/widgets/notification_bell.dart';
import 'package:splito_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:splito_flutter/features/expenses/presentation/providers/expense_providers.dart';

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
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => CreateGroupSheet.show(context),
          ),
        ],
      ),
      body: AsyncValueWidget<List<Group>>(
        value: groupsAsync,
        data: (groups) {
          final activeGroups = groups.where((g) => g.isActive).toList();

          if (activeGroups.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.group_outlined,
              title: 'No groups yet',
              subtitle: 'Create a group to start splitting expenses.',
              actionLabel: 'Create Group',
              onAction: () => CreateGroupSheet.show(context),
            );
          }

          final unsettledGroups = <Group>[];
          final settledGroups = <Group>[];

          for (final group in activeGroups) {
            final balancesState = ref.watch(groupBalancesProvider(group.id));
            final balances = balancesState.valueOrNull;

            if (balances != null && balances.isAllSettled) {
              final expensesState = ref.watch(groupExpensesProvider(group.id));
              final expenses = expensesState.valueOrNull;

              if (expenses != null && expenses.totalItems > 0) {
                settledGroups.add(group);
              } else {
                unsettledGroups.add(group);
              }
            } else {
              unsettledGroups.add(group);
            }
          }

          // Sort unsettled groups by createdAt descending (newest on top)
          unsettledGroups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myGroupsProvider);
              ref.invalidate(myOverallBalancesProvider);
              ref.invalidate(unreadCountProvider);
              // Analytics is derived from expenses — invalidating
              // groupExpensesProvider causes analytics to recompute
              // automatically. No explicit analytics invalidation needed.
              try {
                await ref.read(myGroupsProvider.future);
                await ref.read(myOverallBalancesProvider.future);
                await ref.read(unreadCountProvider.future);
              } catch (_) {}
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: OverallBalanceCard(),
                ),
                // Unsettled Groups
                if (unsettledGroups.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = unsettledGroups[index];
                          return GroupCard(group: group);
                        },
                        childCount: unsettledGroups.length,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'No unsettled groups',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                // History Section
                if (settledGroups.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
                      child: Text(
                        'History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = settledGroups[index];
                          return GroupCard(group: group);
                        },
                        childCount: settledGroups.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
