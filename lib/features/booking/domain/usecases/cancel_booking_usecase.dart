import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class CancelBookingUsecaseParams extends Equatable {
  final String bookingId;
  final String reason;

  const CancelBookingUsecaseParams({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}

// Provider for CancelBookingUsecase
final cancelBookingUsecaseProvider = Provider<CancelBookingUsecase>((ref) {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  return CancelBookingUsecase(bookingRepository: bookingRepository);
});

class CancelBookingUsecase
    implements UsecaseWithParams<bool, CancelBookingUsecaseParams> {
  final IBookingRepository _bookingRepository;

  CancelBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, bool>> call(CancelBookingUsecaseParams params) {
    return _bookingRepository.cancelBooking(params.bookingId, params.reason);
  }
}
