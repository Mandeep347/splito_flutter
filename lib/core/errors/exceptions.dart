/// Base class for all remote HTTP or network client exceptions.
abstract class NetworkClientException implements Exception {
  final String message;
  const NetworkClientException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when credentials are invalid or the authentication session has expired (HTTP 401).
class UnauthorizedException extends NetworkClientException {
  const UnauthorizedException([super.message = 'Unauthorized access. Please login again.']);
}

/// Thrown when the authenticated user does not have permission for the requested action (HTTP 403).
class ForbiddenException extends NetworkClientException {
  const ForbiddenException([super.message = 'Access denied. You do not have permissions for this action.']);
}

/// Thrown when the requested resource is not found on the backend (HTTP 404).
class NotFoundException extends NetworkClientException {
  const NotFoundException([super.message = 'Requested resource not found.']);
}

/// Thrown when a conflict state occurs on the database or resource (HTTP 409).
class ConflictException extends NetworkClientException {
  const ConflictException([super.message = 'Resource conflict occurred.']);
}

/// Thrown when request payload fails validation or violates rules (HTTP 422).
class BusinessRuleException extends NetworkClientException {
  final Map<String, dynamic>? errors;

  const BusinessRuleException({
    String message = 'Validation and business rule check failed.',
    this.errors,
  }) : super(message);
}

/// Thrown when the server reports internal faults (HTTP 500 range, or general 4xx exception).
class ServerException extends NetworkClientException {
  final int? statusCode;

  const ServerException({
    required String message,
    this.statusCode,
  }) : super(message);
}

/// Thrown when socket connection drops or timeouts occur.
class NetworkException extends NetworkClientException {
  const NetworkException([super.message = 'Network connection failed. Please check your internet.']);
}
