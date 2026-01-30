import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/hotel/data/datasources/remote/hotel_remote_datasource.dart';
import 'package:hotelspot/features/hotel/data/hotel_datasource.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';

final hotelRepositoryProvider = Provider<IHotelRepository>((ref) {
  final hotelRemoteDatasource = ref.watch(hotelRemoteDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return HotelRepository(
    hotelRemoteDatasource: hotelRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class HotelRepository implements IHotelRepository {
  final IHotelRemoteDatasource _hotelRemoteDatasource;
  final NetworkInfo _networkInfo;

  HotelRepository({
    required IHotelRemoteDatasource hotelRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _hotelRemoteDatasource = hotelRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createHotel(HotelEntity hotel) {
    // TODO: implement createHotel
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> deleteHotel(String hotelId) {
    // TODO: implement deleteHotel
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<HotelEntity>>> getAllHotels() {
    // TODO: implement getAllHotels
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, HotelEntity>> getHotelById(String hotelId) {
    // TODO: implement getHotelById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateHotel(HotelEntity hotel) {
    // TODO: implement updateHotel
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _hotelRemoteDatasource.uploadImage(image);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideo(File video) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _hotelRemoteDatasource.uploadVideo(video);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
