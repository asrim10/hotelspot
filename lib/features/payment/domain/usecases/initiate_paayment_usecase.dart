import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';

import 'package:hotelspot/features/payment/data/repositories/payment_repository.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/repositories/payment_repository.dart';

class InitiatePaymentParams extends Equatable {
  final String bookingId;
  final double totalPrice;
  final String fullName;
  final String email;

  const InitiatePaymentParams({
    required this.bookingId,
    required this.totalPrice,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [bookingId, totalPrice, fullName, email];
}

final initiatePaymentUsecaseProvider = Provider<InitiatePaymentUsecase>((ref) {
  final paymentRepository = ref.read(paymentRepositoryProvider);
  return InitiatePaymentUsecase(paymentRepository: paymentRepository);
});

class InitiatePaymentUsecase
    implements UsecaseWithParams<PaymentEntity, InitiatePaymentParams> {
  final IPaymentRepository _paymentRepository;

  InitiatePaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, PaymentEntity>> call(InitiatePaymentParams params) {
    return _paymentRepository.initiateKhaltiPayment(
      bookingId: params.bookingId,
      totalPrice: params.totalPrice,
      fullName: params.fullName,
      email: params.email,
    );
  }
}
