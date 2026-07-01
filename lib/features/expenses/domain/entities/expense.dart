import 'expense_participant.dart';
import 'split_type.dart';

/// Represents a single expense record in a group.
class Expense {
  /// The unique identifier of the expense.
  final String id;

  /// The unique identifier of the group this expense belongs to.
  final String groupId;

  /// The user ID of the person who paid for the expense.
  final String paidByUserId;

  /// The display name of the person who paid for the expense.
  final String paidByName;

  /// The title of the expense.
  final String title;

  /// Optional description of the expense.
  final String? description;

  /// The total transaction amount of the expense.
  final double totalAmount;

  /// The currency code of the expense.
  final String currency;

  /// The split strategy used to divide this expense.
  final SplitType splitType;

  /// The status of this expense (e.g. 'ACTIVE', 'REVERSED', 'SETTLED').
  final String status;

  /// The date and time when the expense was created.
  final DateTime createdAt;

  /// The participants involved in the split.
  final List<ExpenseParticipant> participants;

  /// Creates a new [Expense] instance.
  const Expense({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.paidByName,
    required this.title,
    this.description,
    required this.totalAmount,
    required this.currency,
    required this.splitType,
    required this.status,
    required this.createdAt,
    this.participants = const [],
  });

  /// Check if the expense is active.
  bool get isActive => status == 'ACTIVE';

  /// Check if the expense has been reversed.
  bool get isReversed => status == 'REVERSED';

  /// Check if the expense is fully settled.
  bool get isSettled => status == 'SETTLED';
}
