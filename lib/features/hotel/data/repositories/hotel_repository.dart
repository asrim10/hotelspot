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
            'imageUrl': hotel.imageUrl, // ONLY imageUrl
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

  @override
  Future<Either<Failure, bool>> deleteHotel(String hotelId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _hotelRemoteDatasource.deleteHotel(hotelId);
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<HotelEntity>>> getAllHotels() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _hotelRemoteDatasource.getAllHotels();
        final hotels = result
            .map(
              (hotelData) => HotelEntity(
                hotelId: hotelData['_id'],
                hotelName: hotelData['hotelName'] ?? '',
                city: hotelData['city'] ?? '',
                price: (hotelData['price'] ?? 0).toDouble(),
                country: hotelData['country'] ?? '',
                address: hotelData['address'] ?? '',
                availableRooms: hotelData['availableRooms'] ?? 0,
                rating: (hotelData['rating'] ?? 0).toDouble(),
                description: hotelData['description'],
                imageUrl: hotelData['imageUrl'],
              ),
            )
            .toList();
        return Right(hotels);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, HotelEntity>> getHotelById(String hotelId) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _hotelRemoteDatasource.getHotelById(hotelId);
        final hotel = HotelEntity(
          hotelId: response['_id'],
          hotelName: response['hotelName'] ?? '',
          city: response['city'] ?? '',
          price: (response['price'] ?? 0).toDouble(),
          country: response['country'] ?? '',
          address: response['address'] ?? '',
          availableRooms: response['availableRooms'] ?? 0,
          rating: (response['rating'] ?? 0).toDouble(),
          description: response['description'],
          imageUrl: response['imageUrl'],
        );
        return Right(hotel);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

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
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
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
