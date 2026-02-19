import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

class DeleteHotelParams extends Equatable {
  final String hotelId;

  const DeleteHotelParams({required this.hotelId});

  @override
  List<Object?> get props => [hotelId];
}

//Provider for DeleteHotelUsecase
final deleteHotelUsecaseProvider = Provider<DeleteHotelUsecase>((ref) {
  final hotelRepository = ref.read(hotelRepositoryProvider);
  return DeleteHotelUsecase(hotelRepository: hotelRepository);
});

class DeleteHotelUsecase implements UsecaseWithParams<bool, DeleteHotelParams> {
  final IHotelRepository _hotelRepository;

  DeleteHotelUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteHotelParams params) {
    return _hotelRepository.deleteHotel(params.hotelId);
  }
}
