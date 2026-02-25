import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/payment/data/repositories/payment_repository.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/repositories/payment_repository.dart';

class VerifyPaymentParams extends Equatable {
  final String pidx;

  const VerifyPaymentParams({required this.pidx});

  @override
  List<Object?> get props => [pidx];
}

final verifyPaymentUsecaseProvider = Provider<VerifyPaymentUsecase>((ref) {
  final paymentRepository = ref.read(paymentRepositoryProvider);
  return VerifyPaymentUsecase(paymentRepository: paymentRepository);
});

class VerifyPaymentUsecase
    implements UsecaseWithParams<PaymentEntity, VerifyPaymentParams> {
  final IPaymentRepository _paymentRepository;

  VerifyPaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, PaymentEntity>> call(VerifyPaymentParams params) {
    return _paymentRepository.verifyKhaltiPayment(params.pidx);
  }
}
