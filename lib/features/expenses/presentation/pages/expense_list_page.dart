import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/features/expenses/domain/entities/paginated_expenses.dart';
import 'package:splito_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splito_flutter/features/expenses/presentation/widgets/expense_list_tile.dart';
import 'package:splito_flutter/features/groups/domain/entities/group_member.dart';
import 'package:splito_flutter/features/groups/presentation/providers/group_providers.dart';
import 'package:splito_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:splito_flutter/shared/widgets/async_value_widget.dart';
import 'package:splito_flutter/shared/widgets/empty_state_widget.dart';

/// Screen displaying a paginated list of expenses for a specific group.
class ExpenseListPage extends ConsumerStatefulWidget {
  /// The unique identifier of the group.
  final String groupId;

  /// The name of the group.
  final String groupName;

  /// Creates a const [ExpenseListPage] instance.
  const ExpenseListPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(groupExpensesProvider(widget.groupId).notifier).loadNextPage();
    }
  }

  void _navigateToAddExpense() {
    final group = ref.read(groupDetailProvider(widget.groupId)).valueOrNull;
    if (group != null) {
      context.goNamed(
        AppRoutes.createExpenseName,
        pathParameters: {'groupId': widget.groupId},
        extra: {
          'groupName': group.name,
          'currency': group.defaultCurrency,
          'members': group.members,
        },
      );
    } else {
      context.goNamed(
        AppRoutes.createExpenseName,
        pathParameters: {'groupId': widget.groupId},
        extra: {
          'groupName': widget.groupName,
          'currency': 'INR',
          'members': <GroupMember>[],
        },
      );
    }
  }

  Future<void> _onRefresh() async {
    ref.read(groupExpensesProvider(widget.groupId).notifier).refresh();
    try {
      await ref.read(groupExpensesProvider(widget.groupId).future);
    } catch (_) {
      // Ignore errors so pull-to-refresh indicator completes
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupExpensesProvider(widget.groupId));
    final isCompact = ref.watch(settingsProvider).valueOrNull?.compactExpenseList ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddExpense,
          ),
        ],
      ),
      body: AsyncValueWidget<PaginatedExpenses>(
        value: state,
        onRetry: _onRefresh,
        data: (paginatedData) {
          final items = paginatedData.items;

          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses yet',
              subtitle: 'Add the first expense for ${widget.groupName}.',
              actionLabel: 'Add Expense',
              onAction: _navigateToAddExpense,
            );
          }

          final hasMore = paginatedData.hasMore;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: isCompact
                  ? const EdgeInsets.fromLTRB(12, 8, 12, 100)
                  : const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: items.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return ExpenseListTile(
                  expense: items[index],
                  compact: isCompact,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
