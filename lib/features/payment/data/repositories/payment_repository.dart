import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/payment/data/datasources/payment_datasource.dart';
import 'package:hotelspot/features/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  final paymentRemoteDatasource = ref.watch(paymentRemoteDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return PaymentRepository(
    paymentRemoteDatasource: paymentRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class PaymentRepository implements IPaymentRepository {
  final IPaymentRemoteDatasource _paymentRemoteDatasource;
  final NetworkInfo _networkInfo;

  PaymentRepository({
    required IPaymentRemoteDatasource paymentRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _paymentRemoteDatasource = paymentRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PaymentEntity>> initiateKhaltiPayment({
    required String bookingId,
    required double totalPrice,
    required String fullName,
    required String email,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _paymentRemoteDatasource.initiateKhaltiPayment(
          bookingId: bookingId,
          totalPrice: totalPrice,
          fullName: fullName,
          email: email,
        );

        final payment = PaymentEntity(
          bookingId: bookingId,
          totalPrice: totalPrice,
          fullName: fullName,
          email: email,
          pidx: response['pidx'],
          paymentUrl: response['payment_url'],
          paymentMethod: 'online',
          paymentStatus: 'pending',
        );

        return Right(payment);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> verifyKhaltiPayment(
    String pidx,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _paymentRemoteDatasource.verifyKhaltiPayment(
          pidx,
        );

        final payment = PaymentEntity(
          bookingId: response['bookingId'] ?? '',
          totalPrice: (response['amount'] ?? 0).toDouble(),
          fullName: '',
          email: '',
          pidx: pidx,
          transactionId: response['transactionId'],
          paymentMethod: 'online',
          paymentStatus: response['success'] == true ? 'paid' : 'failed',
          khaltiStatus: response['success'] == true ? 'Completed' : 'Failed',
        );

        return Right(payment);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
