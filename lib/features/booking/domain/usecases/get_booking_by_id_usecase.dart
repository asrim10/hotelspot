import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class GetBookingByIdUsecaseParams extends Equatable {
  final String bookingId;

  const GetBookingByIdUsecaseParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

// Provider for GetBookingByIdUsecase
final getBookingByIdUsecaseProvider = Provider<GetBookingByIdUsecase>((ref) {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  return GetBookingByIdUsecase(bookingRepository: bookingRepository);
});

class GetBookingByIdUsecase
    implements UsecaseWithParams<BookingEntity, GetBookingByIdUsecaseParams> {
  final IBookingRepository _bookingRepository;

  GetBookingByIdUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    GetBookingByIdUsecaseParams params,
  ) {
    return _bookingRepository.getBookingById(params.bookingId);
  }
}
