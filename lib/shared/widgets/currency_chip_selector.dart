import 'package:flutter/material.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';

/// A selector widget for currencies using filter chips.
class CurrencyChipSelector extends StatelessWidget {
  /// The currently selected currency.
  final String selectedCurrency;

  /// Callback when a new currency is selected.
  final ValueChanged<String> onChanged;

  /// The list of available currency options.
  final List<String> currencies;

  /// Creates a const [CurrencyChipSelector] instance.
  const CurrencyChipSelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    this.currencies = const ['INR', 'USD', 'EUR', 'GBP', 'SGD', 'AED'],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Wrap(
      spacing: ext.spaceSM,
      runSpacing: ext.spaceSM,
      children: currencies.map((currency) {
        final isSelected = selectedCurrency == currency;

        return FilterChip(
          label: Text(currency),
          selected: isSelected,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
          selectedColor: theme.colorScheme.primaryContainer,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ext.radiusSM),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          onSelected: (selected) {
            if (selected) {
              onChanged(currency);
            }
          },
        );
      }).toList(),
    );
  }
}
