import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';

enum PaymentStatus { initial, loading, initiated, verified, error }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final String? errorMessage;
  final PaymentEntity? payment;
  final String? paymentUrl; // Khalti payment URL to open
  final String? pidx; // to verify after redirect

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.errorMessage,
    this.payment,
    this.paymentUrl,
    this.pidx,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    PaymentEntity? payment,
    String? paymentUrl,
    String? pidx,
  }) {
    return PaymentState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      payment: payment ?? this.payment,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      pidx: pidx ?? this.pidx,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, payment, paymentUrl, pidx];
}
