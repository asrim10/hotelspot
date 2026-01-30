import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

abstract interface class IHotelRepository {
  Future<Either<Failure, List<HotelEntity>>> getAllHotels();
  Future<Either<Failure, HotelEntity>> getHotelById(String hotelId);
  Future<Either<Failure, bool>> createHotel(HotelEntity hotel);
  Future<Either<Failure, bool>> updateHotel(HotelEntity hotel);
  Future<Either<Failure, bool>> deleteHotel(String hotelId);
  Future<Either<Failure, String>> uploadImage(File image);
  Future<Either<Failure, String>> uploadVideo(File video);
}
