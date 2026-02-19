import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUsecaseParams extends Equatable {
  final BookingEntity booking;

  const CreateBookingUsecaseParams({required this.booking});

  @override
  List<Object?> get props => [booking];
}

// Provider for CreateBookingUsecase
final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  return CreateBookingUsecase(bookingRepository: bookingRepository);
});

class CreateBookingUsecase
    implements UsecaseWithParams<BookingEntity, CreateBookingUsecaseParams> {
  final IBookingRepository _bookingRepository;

  CreateBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    CreateBookingUsecaseParams params,
  ) {
    return _bookingRepository.createBooking(params.booking);
  }
}
