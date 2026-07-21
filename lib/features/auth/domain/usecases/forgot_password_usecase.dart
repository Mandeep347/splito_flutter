import 'package:splito_flutter/core/errors/exceptions.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Usecase executing the forgot password flow.
class ForgotPasswordUseCase {
  /// The auth repository interface.
  final IAuthRepository repository;

  /// Creates a new [ForgotPasswordUseCase] instance.
  const ForgotPasswordUseCase({required this.repository});

  /// Executes the forgot password request.
  /// Throws a [Failure] subclass on error.
  Future<void> call({required String email}) async {
    try {
      await repository.forgotPassword(email: email);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.code ?? 'NETWORK_ERROR');
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.code ?? e.statusCode?.toString());
    } on BusinessRuleException catch (e) {
      throw AuthFailure(e.message, e.code ?? 'VALIDATION_ERROR');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message, e.code);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
