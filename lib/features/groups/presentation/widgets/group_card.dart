import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';
import 'package:splito_flutter/features/groups/domain/entities/group.dart';
import 'package:splito_flutter/core/theme/financial_colors.dart';
import 'package:splito_flutter/features/balances/presentation/providers/balance_providers.dart';

/// Card displaying metadata for a single group in lists.
class GroupCard extends ConsumerWidget {
  /// The group info to display.
  final Group group;

  /// Creates a const [GroupCard] instance.
  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final firstLetter = group.name.trim().isNotEmpty ? group.name.trim()[0].toUpperCase() : '';

    final cardContent = Card(
      margin: EdgeInsets.symmetric(horizontal: ext.spaceLG, vertical: ext.spaceXS),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(
            AppRoutes.groupDetailsName,
            pathParameters: {'groupId': group.id},
          );
        },
        child: Padding(
          padding: EdgeInsets.all(ext.spaceMD),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(ext.radiusMD),
                ),
                alignment: Alignment.center,
                child: Text(
                  firstLetter,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: ext.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ext.spaceXXS),
                    Text(
                      '${group.membersCount} members · ${group.defaultCurrency}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ext.spaceXXS),
                    // N+1 balance calls from GroupCard are intentional for Phase 5
                    // to display net outstanding counts inside the list item.
                    ref.watch(groupBalancesProvider(group.id)).when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (balances) {
                            if (balances.isAllSettled) {
                              return Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 12,
                                    color: theme.colorScheme.owedColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'All settled',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.owedColor,
                                    ),
                                  ),
                                ],
                              );
                            }
                            final count = balances.balances.length;
                            return Text(
                              '$count unsettled balance${count == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.oweColor,
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
              if (group.isArchived)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ext.spaceSM, vertical: ext.spaceXS),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(ext.radiusXS),
                  ),
                  child: Text(
                    'ARCHIVED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );

    if (group.isArchived) {
      return Opacity(
        opacity: 0.6,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
