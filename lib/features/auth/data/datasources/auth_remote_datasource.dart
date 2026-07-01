import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/constants/app_constants.dart';
import 'package:splito_flutter/core/network/dio_client.dart';
import '../models/token_response_model.dart';
import '../models/user_model.dart';

/// Abstract contract defining remote operations for the authentication endpoint.
abstract interface class IAuthRemoteDatasource {
  /// Calls POST /auth/login with email and password.
  Future<TokenResponseModel> login({
    required String email,
    required String password,
  });

  /// Calls POST /auth/register with name, email, and password.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Calls POST /auth/refresh with the refresh token.
  Future<TokenResponseModel> refresh({
    required String refreshToken,
  });

  /// Calls GET /users/me to fetch active user profile details.
  Future<UserModel> getMe();

  /// Calls PATCH /users/me to update user profile parameters.
  Future<UserModel> updateMe({
    String? name,
    String? preferredCurrency,
  });
}

/// Remote datasource implementation using [DioClient].
class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final DioClient _client;

  const AuthRemoteDatasource(this._client);

  @override
  Future<TokenResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return TokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<TokenResponseModel> refresh({
    required String refreshToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {
        'refresh_token': refreshToken,
      },
    );
    return TokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.usersMe,
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> updateMe({
    String? name,
    String? preferredCurrency,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (preferredCurrency != null) data['preferred_currency'] = preferredCurrency;

    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.usersMe,
      data: data,
    );
    return UserModel.fromJson(response.data!);
  }
}

/// Provider exposing [IAuthRemoteDatasource].
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDatasource(dioClient);
});
