import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class UpdateBookingStatusUsecaseParams extends Equatable {
  final String bookingId;
  final String status;

  const UpdateBookingStatusUsecaseParams({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}

// Provider for UpdateBookingStatusUsecase
final updateBookingStatusUsecaseProvider = Provider<UpdateBookingStatusUsecase>(
  (ref) {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    return UpdateBookingStatusUsecase(bookingRepository: bookingRepository);
  },
);

class UpdateBookingStatusUsecase
    implements
        UsecaseWithParams<BookingEntity, UpdateBookingStatusUsecaseParams> {
  final IBookingRepository _bookingRepository;

  UpdateBookingStatusUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdateBookingStatusUsecaseParams params,
  ) {
    return _bookingRepository.updateBookingStatus(
      params.bookingId,
      params.status,
    );
  }
}
