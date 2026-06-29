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
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Expanded(
      child: Card(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final detailAsync = ref.watch(groupDetailProvider(groupId));

    // Listen to archive group mutation
    ref.listen<AsyncValue<void>>(archiveGroupProvider, (previous, next) {
      if (next is AsyncData<void> && previous is AsyncLoading<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group archived!')),
        );
        context.pop();
      } else if (next is AsyncError<void> && previous is AsyncLoading<void>) {
        final errorMessage =
            next.error is Failure ? (next.error as Failure).message : 'Failed to archive group.';
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
                      } else if (value == 'archive') {
                        final confirm = await ConfirmationDialog.show(
                          context,
                          title: 'Archive Group',
                          message: 'Are you sure you want to archive this group?',
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
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive Group'),
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

                    // Quick Actions
                    Padding(
                      padding: EdgeInsets.only(bottom: ext.spaceLG),
                      child: Row(
                        children: [
                          _buildActionItem(
                            context,
                            icon: Icons.receipt_long_outlined,
                            label: 'Expenses',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming in Phase 4')),
                              );
                            },
                          ),
                          _buildActionItem(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Balances',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming in Phase 5')),
                              );
                            },
                          ),
                          _buildActionItem(
                            context,
                            icon: Icons.swap_horiz_rounded,
                            label: 'Settle Up',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming in Phase 5')),
                              );
                            },
                          ),
                        ],
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming in Phase 4')),
          );
        },
      ),
    );
  }
}
