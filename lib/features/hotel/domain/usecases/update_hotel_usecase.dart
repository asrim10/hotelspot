import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

class UpdateHotelParams extends Equatable {
  final HotelEntity hotel;

  const UpdateHotelParams({required this.hotel});

  @override
  List<Object?> get props => [hotel];
}

//Provider for UpdateHotelUsecase
final updateHotelUsecaseProvider = Provider<UpdateHotelUsecase>((ref) {
  final hotelRepository = ref.read(hotelRepositoryProvider);
  return UpdateHotelUsecase(hotelRepository: hotelRepository);
});

class UpdateHotelUsecase implements UsecaseWithParams<bool, UpdateHotelParams> {
  final IHotelRepository _hotelRepository;

  UpdateHotelUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateHotelParams params) {
    return _hotelRepository.updateHotel(params.hotel);
  }
}
