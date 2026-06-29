import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/storage/token_storage_service.dart';
import 'package:splito_flutter/features/auth/domain/entities/auth_tokens.dart';
import 'package:splito_flutter/features/auth/domain/entities/logged_in_user.dart';
import 'package:splito_flutter/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of the domain [IAuthRepository] contract.
class AuthRepositoryImpl implements IAuthRepository {
  /// The remote datasource dependency.
  final IAuthRemoteDatasource datasource;

  /// The token secure storage service dependency.
  final ITokenStorageService tokenStorage;

  /// The local datasource dependency.
  final IAuthLocalDatasource localDatasource;

  /// Creates a new [AuthRepositoryImpl] instance.
  const AuthRepositoryImpl({
    required this.datasource,
    required this.tokenStorage,
    required this.localDatasource,
  });

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenResponse = await datasource.login(email: email, password: password);
      await tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );
      return tokenResponse.toEntity();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, 'UNAUTHORIZED');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, 'NETWORK_ERROR');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LoggedInUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await datasource.register(
        name: name,
        email: email,
        password: password,
      );
      // Auto-authenticate after successful registration to save JWT tokens
      await login(email: email, password: password);
      return userModel.toEntity();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, 'UNAUTHORIZED');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, 'NETWORK_ERROR');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthTokens> refreshTokens({
    required String refreshToken,
  }) async {
    try {
      final tokenResponse = await datasource.refresh(refreshToken: refreshToken);
      await tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );
      return tokenResponse.toEntity();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, 'UNAUTHORIZED');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, 'NETWORK_ERROR');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LoggedInUser> getMe() async {
    try {
      final userModel = await datasource.getMe();
      await localDatasource.cacheUser(userModel);
      return userModel.toEntity();
    } on NetworkException catch (e) {
      final cachedUser = await localDatasource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser.toEntity();
      }
      throw NetworkFailure(e.message, 'NETWORK_ERROR');
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, 'UNAUTHORIZED');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await tokenStorage.clearTokens();
      await localDatasource.clearCachedUser();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await tokenStorage.hasTokens();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LoggedInUser> updateMe({
    String? name,
    String? preferredCurrency,
  }) async {
    try {
      final userModel = await datasource.updateMe(
        name: name,
        preferredCurrency: preferredCurrency,
      );
      return userModel.toEntity();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, 'UNAUTHORIZED');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, 'NETWORK_ERROR');
    } on NetworkClientException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

/// Provider exposing [IAuthRepository] implementation.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  final localDatasource = ref.watch(authLocalDatasourceProvider);
  return AuthRepositoryImpl(
    datasource: datasource,
    tokenStorage: tokenStorage,
    localDatasource: localDatasource,
  );
});
