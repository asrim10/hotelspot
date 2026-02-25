import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/hotel/data/datasources/local/hotel_local_datasource.dart';
import 'package:hotelspot/features/hotel/data/datasources/remote/hotel_remote_datasource.dart';
import 'package:hotelspot/features/hotel/data/hotel_datasource.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_hive_model.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';

final hotelRepositoryProvider = Provider<IHotelRepository>((ref) {
  final hotelRemoteDatasource = ref.watch(hotelRemoteDatasourceProvider);
  final hotelLocalDatasource = ref.watch(hotelLocalDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return HotelRepository(
    hotelRemoteDatasource: hotelRemoteDatasource,
    hotelLocalDatasource: hotelLocalDatasource,
    networkInfo: networkInfo,
  );
});

class HotelRepository implements IHotelRepository {
  final IHotelRemoteDatasource _hotelRemoteDatasource;
  final IHotelLocalDatasource _hotelLocalDatasource;
  final NetworkInfo _networkInfo;

  HotelRepository({
    required IHotelRemoteDatasource hotelRemoteDatasource,
    required IHotelLocalDatasource hotelLocalDatasource,
    required NetworkInfo networkInfo,
  }) : _hotelRemoteDatasource = hotelRemoteDatasource,
       _hotelLocalDatasource = hotelLocalDatasource,
       _networkInfo = networkInfo;

  //  GET ALL HOTELS

  @override
  Future<Either<Failure, List<HotelEntity>>> getAllHotels() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _hotelRemoteDatasource.getAllHotels();
        print('imageUrl from API: ${apiModels.first.imageUrl}');

        final hotels = apiModels.map((m) => m.toEntity()).toList();

        // Cache fresh data locally
        final hiveModels = HotelHiveModel.fromApiModelList(apiModels);
        await _hotelLocalDatasource.cacheHotels(hiveModels);

        return Right(hotels);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline fallback
      try {
        final hiveModels = await _hotelLocalDatasource.getAllHotels();
        final hotels = HotelHiveModel.toEntityList(hiveModels);
        return Right(hotels);
      } catch (e) {
        return Left(ApiFailure(message: 'No internet connection'));
      }
    }
  }

  //  GET HOTEL BY ID

  @override
  Future<Either<Failure, HotelEntity>> getHotelById(String hotelId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _hotelRemoteDatasource.getHotelById(hotelId);
        final hotel = apiModel.toEntity();

        // Cache individually
        final hiveModel = HotelHiveModel.fromApiModel(apiModel);
        await _hotelLocalDatasource.saveHotel(hiveModel);

        return Right(hotel);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline fallback
      final hiveModel = await _hotelLocalDatasource.getHotelById(hotelId);
      if (hiveModel != null) return Right(hiveModel.toEntity());
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  //  CREATE HOTEL

  @override
  Future<Either<Failure, bool>> createHotel(HotelEntity hotel) async {
    if (await _networkInfo.isConnected) {
      try {
        final hotelData = {
          'hotelName': hotel.hotelName,
          'city': hotel.city,
          'price': hotel.price,
          'country': hotel.country,
          'address': hotel.address,
          'availableRooms': hotel.availableRooms,
          'rating': hotel.rating,
          'description': hotel.description,
          if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
            'imageUrl': hotel.imageUrl,
        };
        final result = await _hotelRemoteDatasource.createHotel(hotelData);
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  //  UPDATE HOTEL

  @override
  Future<Either<Failure, bool>> updateHotel(HotelEntity hotel) async {
    if (await _networkInfo.isConnected) {
      try {
        final hotelData = {
          'hotelName': hotel.hotelName,
          'city': hotel.city,
          'price': hotel.price,
          'country': hotel.country,
          'address': hotel.address,
          'availableRooms': hotel.availableRooms,
          'rating': hotel.rating,
          'description': hotel.description,
          if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
            'imageUrl': hotel.imageUrl,
        };
        final result = await _hotelRemoteDatasource.updateHotel(
          hotel.hotelId!,
          hotelData,
        );

        // Sync updated hotel to local cache
        if (result && hotel.hotelId != null) {
          final hiveModel = HotelHiveModel.fromEntity(hotel);
          await _hotelLocalDatasource.saveHotel(hiveModel);
        }

        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  //  DELETE HOTEL

  @override
  Future<Either<Failure, bool>> deleteHotel(String hotelId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _hotelRemoteDatasource.deleteHotel(hotelId);

        // Remove from local cache
        if (result) {
          await _hotelLocalDatasource.deleteHotel(hotelId);
        }

        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  //  UPLOAD IMAGE

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final imageUrl = await _hotelRemoteDatasource.uploadImage(image);
        return Right(imageUrl);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  //  UPLOAD VIDEO

  @override
  Future<Either<Failure, String>> uploadVideo(File video) async {
    if (await _networkInfo.isConnected) {
      try {
        final videoUrl = await _hotelRemoteDatasource.uploadVideo(video);
        return Right(videoUrl);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
