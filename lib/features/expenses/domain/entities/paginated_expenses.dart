import 'expense.dart';

/// Represents a paginated list response of [Expense] items.
class PaginatedExpenses {
  /// The list of expense items returned in the current page.
  final List<Expense> items;

  /// The current page number (1-indexed).
  final int page;

  /// The limit number of items per page.
  final int limit;

  /// The total number of pages available.
  final int totalPages;

  /// The total number of expense items.
  final int totalItems;

  /// Creates a new [PaginatedExpenses] instance.
  const PaginatedExpenses({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
  });

  /// Check if there are more pages of expenses to load.
  bool get hasMore => page < totalPages;
}
