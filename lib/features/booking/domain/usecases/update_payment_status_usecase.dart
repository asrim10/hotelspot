import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class UpdatePaymentStatusUsecaseParams extends Equatable {
  final String bookingId;
  final String paymentStatus;

  const UpdatePaymentStatusUsecaseParams({
    required this.bookingId,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [bookingId, paymentStatus];
}

// Provider for UpdatePaymentStatusUsecase
final updatePaymentStatusUsecaseProvider = Provider<UpdatePaymentStatusUsecase>(
  (ref) {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    return UpdatePaymentStatusUsecase(bookingRepository: bookingRepository);
  },
);

class UpdatePaymentStatusUsecase
    implements
        UsecaseWithParams<BookingEntity, UpdatePaymentStatusUsecaseParams> {
  final IBookingRepository _bookingRepository;

  UpdatePaymentStatusUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdatePaymentStatusUsecaseParams params,
  ) {
    return _bookingRepository.updatePaymentStatus(
      params.bookingId,
      params.paymentStatus,
    );
  }
}
