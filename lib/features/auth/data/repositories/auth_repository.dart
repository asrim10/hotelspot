import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/auth/data/datasources/auth_datasource.dart';
import 'package:hotelspot/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:hotelspot/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:hotelspot/features/auth/data/models/auth_api_model.dart';
import 'package:hotelspot/features/auth/data/models/auth_hive_model.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authLocalDatasource: ref.read(authLocalDatasourceProvider),
    authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDataSource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDataSource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser();
      if (user != null) return Right(user.toEntity());
      return Left(LocalDatabaseFailure(message: 'No current user found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) return Right(apiModel.toEntity());
        return const Left(ApiFailure(message: 'Invalid Credentials'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.login(email, password);
        if (user != null) return Right(user.toEntity());
        return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(user);
        final result = await _authLocalDatasource.register(model);
        if (result) return const Right(true);
        return Left(LocalDatabaseFailure(message: 'Failed to register user'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  @override
  Future<Either<Failure, AuthEntity>> getProfile() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.getProfile();

        // Cache to Hive
        final hiveModel = AuthHiveModel.fromEntity(apiModel.toEntity());
        await _authLocalDatasource.register(hiveModel);

        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to get profile',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.getCurrentUser();
        if (user != null) return Right(user.toEntity());
        return const Left(
          LocalDatabaseFailure(message: 'No cached profile found'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.updateProfile(
          fullName: fullName,
          username: username,
          phoneNumber: phoneNumber,
          image: image,
        );

        // Cache updated profile to Hive
        final hiveModel = AuthHiveModel.fromEntity(apiModel.toEntity());
        await _authLocalDatasource.register(hiveModel);

        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to update profile',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
