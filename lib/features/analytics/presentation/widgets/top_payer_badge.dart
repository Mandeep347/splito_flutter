import 'package:flutter/material.dart';
import 'package:splito_flutter/features/analytics/domain/entities/member_contribution.dart';
import 'package:splito_flutter/shared/widgets/member_avatar.dart';
import 'package:splito_flutter/shared/widgets/amount_display.dart';

/// Card banner highlighting the group's highest payer.
class TopPayerBadge extends StatelessWidget {
  /// The member contribution of the highest payer.
  final MemberContribution contribution;

  /// The currency code.
  final String currency;

  /// Creates a new [TopPayerBadge] instance.
  const TopPayerBadge({
    super.key,
    required this.contribution,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (contribution.totalPaid == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      color: Colors.amber.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Top Payer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contribution.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountDisplay(
                  amount: contribution.totalPaid,
                  currency: currency,
                  color: theme.colorScheme.onPrimaryContainer,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const Spacer(),
            MemberAvatar(
              name: contribution.name,
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
