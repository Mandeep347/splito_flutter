import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import 'package:splito_flutter/features/expenses/domain/repositories/i_expense_repository.dart';
import 'package:splito_flutter/features/settlements/domain/repositories/i_settlement_repository.dart';
import '../entities/group_analytics.dart';
import '../services/analytics_computation_service.dart';

/// Usecase returning aggregated statistical properties computed client-side for a group.
class ComputeGroupAnalyticsUseCase {
  /// The expense repository interface.
  final IExpenseRepository expenseRepository;

  /// The settlement repository interface.
  final ISettlementRepository settlementRepository;

  /// The analytical computation service.
  final AnalyticsComputationService computationService;

  /// Creates a const [ComputeGroupAnalyticsUseCase] instance.
  const ComputeGroupAnalyticsUseCase({
    required this.expenseRepository,
    required this.settlementRepository,
    required this.computationService,
  });

  /// Executes the usecase.
  /// Throws [Failure] subclass on error.
  Future<GroupAnalytics> call({
    required String groupId,
    required String currency,
  }) async {
    try {
      final paginatedExpenses = await expenseRepository.getGroupExpenses(
        groupId: groupId,
        page: 1,
        limit: 1000,
      );
      final settlements = await settlementRepository.getGroupSettlements(
        groupId: groupId,
      );

      return computationService.computeGroupAnalytics(
        groupId: groupId,
        currency: currency,
        expenses: paginatedExpenses.items,
        settlements: settlements,
      );
    } on Failure {
      rethrow;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
