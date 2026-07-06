import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';
import 'package:splito_flutter/features/groups/domain/entities/group.dart';
import 'package:splito_flutter/features/groups/presentation/providers/group_providers.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/add_member_sheet.dart';
import 'package:splito_flutter/features/groups/presentation/widgets/edit_group_name_sheet.dart';
import 'package:splito_flutter/shared/widgets/async_value_widget.dart';
import 'package:splito_flutter/shared/widgets/confirmation_dialog.dart';
import 'package:splito_flutter/shared/widgets/info_row.dart';
import 'package:splito_flutter/shared/widgets/member_avatar.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/core/theme/financial_colors.dart';
import 'package:splito_flutter/features/balances/presentation/providers/balance_providers.dart';
import 'package:splito_flutter/features/balances/domain/entities/group_balances.dart';
import 'package:splito_flutter/shared/widgets/balance_row.dart';
import 'package:splito_flutter/features/activity/presentation/providers/activity_providers.dart';
import 'package:splito_flutter/features/activity/presentation/widgets/activity_list_tile.dart';
import 'package:splito_flutter/features/activity/domain/entities/activity_feed.dart';

/// Screen displaying the details of a single group.
class GroupDetailsPage extends ConsumerWidget {
  /// The unique identifier of the group.
  final String groupId;

  /// Creates a const [GroupDetailsPage] instance.
  const GroupDetailsPage({
    super.key,
    required this.groupId,
  });

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double? width,
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Widget card = Card(
      margin: EdgeInsets.symmetric(horizontal: ext.spaceXS),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ext.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: ext.spaceXS),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    if (width != null) {
      card = SizedBox(width: width, child: card);
    }
    return card;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final detailAsync = ref.watch(groupDetailProvider(groupId));
    final group = detailAsync.valueOrNull;
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = group != null &&
        (group.createdBy == currentUser?.id ||
            group.members.any((m) => m.userId == currentUser?.id && m.isAdmin));

    // Listen to delete group mutation
    ref.listen<AsyncValue<void>>(archiveGroupProvider, (previous, next) {
      if (next is AsyncData<void> && previous is AsyncLoading<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group deleted!')),
        );
        context.pop();
      } else if (next is AsyncError<void> && previous is AsyncLoading<void>) {
        final errorMessage =
            next.error is Failure ? (next.error as Failure).message : 'Failed to delete group.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: AsyncValueWidget<Group>(
        value: detailAsync,
        data: (group) {
          final shownMembers = group.members.take(6).toList();
          final extraCount = group.members.length - 6;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    group.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await EditGroupNameSheet.show(context, group);
                      } else if (value == 'delete') {
                        final confirm = await ConfirmationDialog.show(
                          context,
                          title: 'Delete Group',
                          message: 'Are you sure you want to delete this group?',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          await ref.read(archiveGroupProvider.notifier).archive(groupId: groupId);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Name'),
                      ),
                      if (isAdmin)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Group'),
                        ),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(ext.spaceLG),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Members Card
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: ext.spaceLG),
                      child: InkWell(
                        onTap: () {
                          context.goNamed(
                            AppRoutes.groupMembersName,
                            pathParameters: {'groupId': group.id},
                            extra: {'createdBy': group.createdBy},
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(ext.spaceMD),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Members (${group.membersCount})',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async => await AddMemberSheet.show(context, groupId),
                                    child: const Text('+ Add'),
                                  ),
                                ],
                              ),
                              SizedBox(height: ext.spaceSM),
                              if (group.members.isEmpty)
                                Text(
                                  'No members yet',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: ext.spaceSM,
                                  runSpacing: ext.spaceSM,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ...shownMembers
                                        .map((m) => MemberAvatar(name: m.name, radius: 18)),
                                    if (extraCount > 0)
                                      Padding(
                                        padding: EdgeInsets.only(left: ext.spaceXS),
                                        child: Text(
                                          '+$extraCount more',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Balances Preview Card
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: ext.spaceLG),
                      child: Padding(
                        padding: EdgeInsets.all(ext.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balances',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: ext.spaceSM),
                            AsyncValueWidget<GroupBalances>(
                              value: ref.watch(groupBalancesProvider(groupId)),
                              loading: () => const SizedBox(
                                height: 48,
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (groupBalances) {
                                if (groupBalances.isAllSettled) {
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: theme.colorScheme.owedColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'All settled up!',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final balances = groupBalances.balances;
                                final shown = balances.take(3).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...shown.map((b) => BalanceRow(
                                          balance: b,
                                          showSettleButton: false,
                                        )),
                                    if (balances.length > 3)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            context.goNamed(
                                              AppRoutes.groupBalancesName,
                                              pathParameters: {'groupId': groupId},
                                              extra: {
                                                'groupName': group.name,
                                                'currency': group.defaultCurrency,
                                              },
                                            );
                                          },
                                          child: const Text('See all'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recent Activity Preview Card
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: ext.spaceLG),
                      child: Padding(
                        padding: EdgeInsets.all(ext.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: ext.spaceSM),
                            AsyncValueWidget<ActivityFeed>(
                              value: ref.watch(groupActivityProvider(groupId)),
                              loading: () => const SizedBox(
                                height: 48,
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (feed) {
                                if (feed.items.isEmpty) {
                                  return Text(
                                    'No activity yet',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                }

                                final recent = feed.items.take(3).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...recent.map((activity) => ActivityListTile(
                                          activity: activity,
                                        )),
                                    if (feed.totalItems > 3)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            context.goNamed(
                                              AppRoutes.activityFeedName,
                                              pathParameters: {'groupId': groupId},
                                              extra: {
                                                'groupName': group.name,
                                              },
                                            );
                                          },
                                          child: const Text('View all'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quick Actions
                    Padding(
                      padding: EdgeInsets.only(bottom: ext.spaceLG),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth > 600 ? 4 : 2;
                          final itemWidth = constraints.maxWidth / columns;

                          return Wrap(
                            runSpacing: ext.spaceSM,
                            children: [
                              _buildActionItem(
                                context,
                                icon: Icons.receipt_long_outlined,
                                label: 'Expenses',
                                width: itemWidth,
                                onTap: () {
                                  context.goNamed(
                                    AppRoutes.expenseListName,
                                    pathParameters: {'groupId': group.id},
                                    extra: {'groupName': group.name},
                                  );
                                },
                              ),
                              _buildActionItem(
                                context,
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Balances',
                                width: itemWidth,
                                onTap: () {
                                  context.goNamed(
                                    AppRoutes.groupBalancesName,
                                    pathParameters: {'groupId': group.id},
                                    extra: {
                                      'groupName': group.name,
                                      'currency': group.defaultCurrency,
                                    },
                                  );
                                },
                              ),
                              _buildActionItem(
                                context,
                                icon: Icons.swap_horiz_rounded,
                                label: 'Settle Up',
                                width: itemWidth,
                                onTap: () {
                                  context.goNamed(
                                    AppRoutes.createSettlementName,
                                    pathParameters: {'groupId': group.id},
                                    extra: {
                                      'groupName': group.name,
                                      'currency': group.defaultCurrency,
                                      'members': group.members,
                                    },
                                  );
                                },
                              ),
                              _buildActionItem(
                                context,
                                icon: Icons.history_outlined,
                                label: 'Activity',
                                width: itemWidth,
                                onTap: () {
                                  context.goNamed(
                                    AppRoutes.activityFeedName,
                                    pathParameters: {'groupId': group.id},
                                    extra: {
                                      'groupName': group.name,
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Meta Info Card
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(ext.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Info',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: ext.spaceMD),
                            InfoRow(
                              icon: Icons.attach_money_rounded,
                              label: 'Default Currency',
                              value: group.defaultCurrency,
                            ),
                            Divider(height: ext.spaceLG),
                            InfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Created On',
                              value: DateFormat('d MMM yyyy').format(group.createdAt),
                            ),
                            Divider(height: ext.spaceLG),
                            InfoRow(
                              icon: Icons.info_outline_rounded,
                              label: 'Status',
                              value: group.status,
                              valueColor: group.isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: group == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              onPressed: () => context.goNamed(
                AppRoutes.createExpenseName,
                pathParameters: {'groupId': group.id},
                extra: {
                  'groupName': group.name,
                  'currency': group.defaultCurrency,
                  'members': group.members,
                },
              ),
            ),
    );
  }
}
