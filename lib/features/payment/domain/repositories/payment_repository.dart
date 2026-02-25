import 'package:dartz/dartz.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';

abstract interface class IPaymentRepository {
  Future<Either<Failure, PaymentEntity>> initiateKhaltiPayment({
    required String bookingId,
    required double totalPrice,
    required String fullName,
    required String email,
  });

  Future<Either<Failure, PaymentEntity>> verifyKhaltiPayment(String pidx);
}
