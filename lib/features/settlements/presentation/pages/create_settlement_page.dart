import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/groups/domain/entities/group_member.dart';
import 'package:splito_flutter/features/settlements/domain/entities/settlement.dart';
import 'package:splito_flutter/features/settlements/presentation/providers/settlement_providers.dart';
import 'package:splito_flutter/shared/widgets/app_text_field.dart';
import 'package:splito_flutter/shared/widgets/settle_up_button.dart';

/// Screen form to record a new debt settlement transaction.
class CreateSettlementPage extends ConsumerStatefulWidget {
  /// The unique identifier of the group.
  final String groupId;

  /// The name of the group.
  final String groupName;

  /// The default currency code.
  final String currency;

  /// The list of members in this group.
  final List<GroupMember> members;

  /// Prefilled user ID representing the payer (who paid).
  final String? prefilledFromUserId;

  /// Prefilled user ID representing the payee (who was paid).
  final String? prefilledToUserId;

  /// Creates a const [CreateSettlementPage] instance.
  const CreateSettlementPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currency,
    required this.members,
    this.prefilledFromUserId,
    this.prefilledToUserId,
  });

  @override
  ConsumerState<CreateSettlementPage> createState() => _CreateSettlementPageState();
}

class _CreateSettlementPageState extends ConsumerState<CreateSettlementPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedFromUserId;
  String? _selectedToUserId;

  @override
  void initState() {
    super.initState();
    _selectedFromUserId = widget.prefilledFromUserId ?? ref.read(currentUserProvider)?.id;
    _selectedToUserId = widget.prefilledToUserId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currencyCode ';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFromUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }
    if (_selectedToUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who was paid')),
      );
      return;
    }
    if (_selectedFromUserId == _selectedToUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot settle with yourself')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    try {
      await ref.read(createSettlementProvider.notifier).create(
            groupId: widget.groupId,
            fromUserId: _selectedFromUserId!,
            toUserId: _selectedToUserId!,
            amount: amount,
            currency: widget.currency,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          );
    } catch (_) {
      // Silent catch to suppress duplicate UI popups
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = _getCurrencySymbol(widget.currency);
    final createSettlementState = ref.watch(createSettlementProvider);

    // Listen to provider states to handle popping on success or displaying failure overlays
    ref.listen<AsyncValue<Settlement?>>(createSettlementProvider, (previous, next) {
      if (next is AsyncData<Settlement?> && previous is AsyncLoading<Settlement?>) {
        final settlement = next.value;
        if (settlement != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${settlement.fromUserName} paid ${settlement.toUserName}'),
            ),
          );
          context.pop();
        }
      } else if (next is AsyncError<Settlement?> && previous is AsyncLoading<Settlement?>) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Failed to record payment.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Who paid?
              Text(
                'Who paid?',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.members.map((member) {
                    final isSelected = member.userId == _selectedFromUserId;
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
                        onSelected: (_) {
                          setState(() {
                            _selectedFromUserId = member.userId;
                            if (_selectedFromUserId == _selectedToUserId) {
                              _selectedToUserId = null;
                            }
                          });
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Paid to?
              Text(
                'Paid to?',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.members
                      .where((m) => m.userId != _selectedFromUserId)
                      .map((member) {
                    final isSelected = member.userId == _selectedToUserId;
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
                        onSelected: (_) {
                          setState(() {
                            _selectedToUserId = member.userId;
                          });
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Amount
              AppTextField(
                labelText: 'Amount',
                hintText: '0.00',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    currencySymbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Section 4: Note
              AppTextField(
                labelText: 'Note (Optional)',
                hintText: 'e.g. Paid via UPI, Cash…',
                controller: _noteController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Section 5: Record Payment Button
              SettleUpButton(
                onPressed: _submit,
                isLoading: createSettlementState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
