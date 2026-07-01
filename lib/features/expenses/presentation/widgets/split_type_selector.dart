import 'package:flutter/material.dart';
import 'package:splito_flutter/features/expenses/domain/entities/split_type.dart';

/// Selector widget for choosing the expense split strategy.
class SplitTypeSelector extends StatelessWidget {
  /// The currently selected split strategy.
  final SplitType selectedType;

  /// Callback triggered when split strategy changes.
  final ValueChanged<SplitType> onChanged;

  /// Creates a const [SplitTypeSelector] instance.
  const SplitTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: SplitType.values.map((type) {
        final isSelected = type == selectedType;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ChoiceChip(
              label: Text(
                type.displayLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              showCheckmark: false,
              labelPadding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      }).toList(),
    );
  }
}
