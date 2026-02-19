import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class UpdatePaymentMethodUsecaseParams extends Equatable {
  final String bookingId;
  final String paymentMethod;

  const UpdatePaymentMethodUsecaseParams({
    required this.bookingId,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [bookingId, paymentMethod];
}

// Provider for UpdatePaymentMethodUsecase
final updatePaymentMethodUsecaseProvider = Provider<UpdatePaymentMethodUsecase>(
  (ref) {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    return UpdatePaymentMethodUsecase(bookingRepository: bookingRepository);
  },
);

class UpdatePaymentMethodUsecase
    implements
        UsecaseWithParams<BookingEntity, UpdatePaymentMethodUsecaseParams> {
  final IBookingRepository _bookingRepository;

  UpdatePaymentMethodUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdatePaymentMethodUsecaseParams params,
  ) {
    return _bookingRepository.updatePaymentMethod(
      params.bookingId,
      params.paymentMethod,
    );
  }
}
