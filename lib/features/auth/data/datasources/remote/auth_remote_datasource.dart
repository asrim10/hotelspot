import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/auth/data/datasources/auth_datasource.dart';
import 'package:hotelspot/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
      );

      final token = response.data['token'];
      if (token != null) {
        await _tokenService.saveToken(token);
      }

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return user;
  }

  @override
  Future<AuthApiModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.getProfile);
    final data = response.data['data'] as Map<String, dynamic>;
    final user = AuthApiModel.fromJson(data);

    await _userSessionService.saveUserSession(
      userId: user.id!,
      email: user.email,
      fullName: user.fullName,
      username: user.username,
    );

    return user;
  }

  @override
  Future<AuthApiModel> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {
    final formData = FormData();

    if (fullName != null) formData.fields.add(MapEntry('fullName', fullName));
    if (username != null) formData.fields.add(MapEntry('username', username));
    if (phoneNumber != null) {
      formData.fields.add(MapEntry('phoneNumber', phoneNumber));
    }
    if (image != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    debugPrint('=== UPDATE PROFILE DEBUG ===');
    debugPrint('image is null: ${image == null}');
    debugPrint('image path: ${image?.path}');
    debugPrint(
      'formData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').toList()}',
    );
    debugPrint('formData files: ${formData.files.map((f) => f.key).toList()}');

    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    debugPrint('response data: ${response.data}');

    final data = response.data['data'] as Map<String, dynamic>;
    final user = AuthApiModel.fromJson(data);

    debugPrint('parsed imageUrl: ${user.imageUrl}');

    await _userSessionService.saveUserSession(
      userId: user.id!,
      email: user.email,
      fullName: user.fullName,
      username: user.username,
    );

    return user;
  }
}
