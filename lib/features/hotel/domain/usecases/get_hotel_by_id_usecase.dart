import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

class GetHotelByIdParams extends Equatable {
  final String hotelId;

  const GetHotelByIdParams({required this.hotelId});

  @override
  List<Object?> get props => [hotelId];
}

//Provider for GetHotelByIdUsecase
final getHotelByIdUsecaseProvider = Provider<GetHotelByIdUsecase>((ref) {
  final hotelRepository = ref.read(hotelRepositoryProvider);
  return GetHotelByIdUsecase(hotelRepository: hotelRepository);
});

class GetHotelByIdUsecase
    implements UsecaseWithParams<HotelEntity, GetHotelByIdParams> {
  final IHotelRepository _hotelRepository;

  GetHotelByIdUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, HotelEntity>> call(GetHotelByIdParams params) {
    return _hotelRepository.getHotelById(params.hotelId);
  }
}
