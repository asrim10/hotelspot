// lib/features/hotel/domain/usecases/get_all_hotels_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

final getAllHotelsUsecaseProvider = Provider<GetAllHotelsUsecase>((ref) {
  final hotelRepository = ref.read(hotelRepositoryProvider);
  return GetAllHotelsUsecase(hotelRepository: hotelRepository);
});

class GetAllHotelsUsecase implements UsecaseWithoutParams<List<HotelEntity>> {
  final IHotelRepository _hotelRepository;

  GetAllHotelsUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, List<HotelEntity>>> call() {
    return _hotelRepository.getAllHotels();
  }
}
