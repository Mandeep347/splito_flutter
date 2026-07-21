import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import '../entities/user_analytics.dart';
import '../repositories/i_analytics_repository.dart';

/// Usecase returning personal cross-group analytics statistics for the current user.
class GetUserAnalyticsUseCase {
  /// The analytics repository interface.
  final IAnalyticsRepository repository;

  /// Creates a const [GetUserAnalyticsUseCase] instance.
  const GetUserAnalyticsUseCase({required this.repository});

  /// Executes the usecase.
  /// Throws [Failure] subclass on error.
  Future<UserAnalytics> call() async {
    try {
      return await repository.getUserAnalytics();
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
