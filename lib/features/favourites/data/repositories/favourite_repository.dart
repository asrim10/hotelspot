import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/favourites/data/datasources/favourite_datasource.dart';
import 'package:hotelspot/features/favourites/data/datasources/local/favourite_local_datasource.dart';
import 'package:hotelspot/features/favourites/data/datasources/remote/favourite_remote_datasource.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_api_model.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_hive_model.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

final favouriteRepositoryProvider = Provider<IFavouriteRepository>((ref) {
  final local = ref.read(favouriteLocalDatasourceProvider);
  final remote = ref.read(favouriteRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return FavouriteRepository(
    favouriteLocalDatasource: local,
    favouriteRemoteDatasource: remote,
    networkInfo: networkInfo,
  );
});

class FavouriteRepository implements IFavouriteRepository {
  final IFavouriteLocalDataSource _favouriteLocalDatasource;
  final IFavouriteRemoteDataSource _favouriteRemoteDatasource;
  final NetworkInfo _networkInfo;

  FavouriteRepository({
    required IFavouriteLocalDataSource favouriteLocalDatasource,
    required IFavouriteRemoteDataSource favouriteRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _favouriteLocalDatasource = favouriteLocalDatasource,
       _favouriteRemoteDatasource = favouriteRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, FavouriteEntity>> addToFavourites(
    FavouriteEntity favourite,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = FavouriteApiModel.fromEntity(favourite);
        final result = await _favouriteRemoteDatasource.addToFavourites(
          apiModel,
        );

        // Save locally
        final hiveModel = FavouriteHiveModel.fromEntity(result.toEntity());
        await _favouriteLocalDatasource.addToFavourites(hiveModel);

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to add favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = FavouriteHiveModel.fromEntity(favourite);
        final result = await _favouriteLocalDatasource.addToFavourites(
          hiveModel,
        );
        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<FavouriteEntity>>> getMyFavourites(
    String userId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteFavourites = await _favouriteRemoteDatasource
            .getMyFavourites(userId);

        // Save locally
        for (final fav in remoteFavourites) {
          final hiveModel = FavouriteHiveModel.fromEntity(fav.toEntity());
          await _favouriteLocalDatasource.addToFavourites(hiveModel);
        }

        return Right(remoteFavourites.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch favourites",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localFavourites = await _favouriteLocalDatasource.getMyFavourites(
          userId,
        );
        return Right(localFavourites.map((e) => e.toEntity()).toList());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavourites(String favouriteId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _favouriteRemoteDatasource.removeFromFavourites(
          favouriteId,
        );
        await _favouriteLocalDatasource.removeFromFavourites(favouriteId);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to remove favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _favouriteLocalDatasource.removeFromFavourites(
          favouriteId,
        );
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> removeByHotelId(
    String userId,
    String hotelId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _favouriteRemoteDatasource.removeByHotelId(
          hotelId,
        );
        await _favouriteLocalDatasource.removeByHotelId(userId, hotelId);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to remove favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _favouriteLocalDatasource.removeByHotelId(
          userId,
          hotelId,
        );
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> isHotelFavourited(
    String userId,
    String hotelId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _favouriteRemoteDatasource.isHotelFavourited(
          hotelId,
        );
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to check favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _favouriteLocalDatasource.isHotelFavourited(
          userId,
          hotelId,
        );
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
