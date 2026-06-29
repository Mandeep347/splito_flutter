import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:splito_flutter/core/constants/app_constants.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import 'package:splito_flutter/core/storage/token_storage_service.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';

/// Wrapped network client class managing REST API operations.
class DioClient {
  /// The underlying pre-configured [Dio] client.
  final Dio dio;

  const DioClient(this.dio);
}

/// Interceptor to automatically inject JWT access tokens and run transparent token refreshes.
class _AuthInterceptor extends QueuedInterceptor {
  final Ref _ref;
  final Dio _refreshDio;

  _AuthInterceptor(this._ref)
      : _refreshDio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeoutMs),
        ));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Changed: Added refresh endpoints to auth route skip list to prevent recursive auth interceptor loops
    if (options.path == ApiEndpoints.login ||
        options.path == ApiEndpoints.register ||
        options.path == ApiEndpoints.refresh) {
      return handler.next(options);
    }

    final tokenStorage = _ref.read(tokenStorageServiceProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    
    // Trigger token refresh sequence on 401 Unauthorized errors
    if (response != null &&
        response.statusCode == 401 &&
        err.requestOptions.path != ApiEndpoints.refresh) {
      final tokenStorage = _ref.read(tokenStorageServiceProvider);
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Changed: Removed Options header containing authorization bearer to prevent API token mismatch errors on FastAPI refresh
          final refreshResponse = await _refreshDio.post<dynamic>(
            ApiEndpoints.refresh,
            data: {'refresh_token': refreshToken},
          );

          if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
            final data = refreshResponse.data as Map<String, dynamic>;
            final newAccessToken = data['access_token'] as String;
            final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;

            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Re-attempt the failed original request with the fresh token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final dio = _ref.read(_rawDioProvider);
            final retryResponse = await dio.fetch<dynamic>(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Token refresh failed, purge secure credentials and force logout re-evaluation
          await tokenStorage.clearTokens();
          _ref.invalidate(authProvider);
        }
      } else {
        await tokenStorage.clearTokens();
        _ref.invalidate(authProvider);
      }
    }

    return handler.next(err);
  }
}

/// Interceptor to map network and backend status codes to structured exceptions.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse) {
      final response = err.response;
      final statusCode = response?.statusCode;
      final data = response?.data;
      
      final message = data is Map<String, dynamic>
          ? (data['message'] as String? ?? data['detail'] as String? ?? 'An HTTP error occurred')
          : 'An HTTP error occurred';

      switch (statusCode) {
        case 401:
          return handler.next(err.copyWith(error: UnauthorizedException(message)));
        case 403:
          return handler.next(err.copyWith(error: ForbiddenException(message)));
        case 404:
          return handler.next(err.copyWith(error: NotFoundException(message)));
        case 409:
          return handler.next(err.copyWith(error: ConflictException(message)));
        case 422:
          final errors = data is Map<String, dynamic> ? data['errors'] as Map<String, dynamic>? : null;
          return handler.next(err.copyWith(error: BusinessRuleException(message: message, errors: errors)));
        default:
          return handler.next(err.copyWith(
            error: ServerException(message: message, statusCode: statusCode),
          ));
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return handler.next(err.copyWith(
        error: const NetworkException('Connection timed out or network error occurred.'),
      ));
    }

    return handler.next(err);
  }
}

/// Internal provider exposing raw pre-configured Dio instance.
final _rawDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
    receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeoutMs),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(ref),
    _ErrorInterceptor(),
    // Changed: Conditionally add PrettyDioLogger in debug mode to prevent leaking tokens or data in production environments
    if (kDebugMode)
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
  ]);

  return dio;
});

/// Provider exposing pre-configured [DioClient] instance.
final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(_rawDioProvider);
  return DioClient(dio);
});
