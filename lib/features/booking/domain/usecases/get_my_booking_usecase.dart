import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

// Provider for GetMyBookingsUsecase
final getMyBookingsUsecaseProvider = Provider<GetMyBookingsUsecase>((ref) {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  return GetMyBookingsUsecase(bookingRepository: bookingRepository);
});

class GetMyBookingsUsecase
    implements UsecaseWithoutParams<List<BookingEntity>> {
  final IBookingRepository _bookingRepository;

  GetMyBookingsUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call() {
    return _bookingRepository.getMyBookings();
  }
}
