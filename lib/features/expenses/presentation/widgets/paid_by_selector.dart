import 'package:flutter/material.dart';
import 'package:splito_flutter/features/groups/domain/entities/group_member.dart';

/// Horizontal scroll selector widget to pick which member paid the expense.
class PaidBySelector extends StatelessWidget {
  /// The list of members in the group.
  final List<GroupMember> members;

  /// The currently selected user ID.
  final String? selectedUserId;

  /// Callback triggered when the payer selection changes.
  final ValueChanged<String> onChanged;

  /// Creates a const [PaidBySelector] instance.
  const PaidBySelector({
    super.key,
    required this.members,
    required this.selectedUserId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: members.map((member) {
          final isSelected = member.userId == selectedUserId;
          final firstName = member.name.split(' ').first;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                firstName,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(member.userId),
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
