import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String? paymentId;
  final String bookingId;
  final double totalPrice;
  final String fullName;
  final String email;

  final String? pidx;
  final String? transactionId;
  final String? paymentUrl;

  final String paymentMethod; // cash / card / online
  final String paymentStatus; // pending / paid / failed

  final String?
  khaltiStatus; // Completed / Pending / Initiated / Refunded / Expired / User canceled

  const PaymentEntity({
    this.paymentId,
    required this.bookingId,
    required this.totalPrice,
    required this.fullName,
    required this.email,
    this.pidx,
    this.transactionId,
    this.paymentUrl,
    this.paymentMethod = 'online',
    this.paymentStatus = 'pending',
    this.khaltiStatus,
  });

  @override
  List<Object?> get props => [
    paymentId,
    bookingId,
    totalPrice,
    fullName,
    email,
    pidx,
    transactionId,
    paymentUrl,
    paymentMethod,
    paymentStatus,
    khaltiStatus,
  ];
}
