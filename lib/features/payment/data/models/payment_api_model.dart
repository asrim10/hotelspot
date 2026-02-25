import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_api_model.g.dart';

@JsonSerializable()
class PaymentApiModel {
  final String? paymentId;
  final String bookingId;
  final double totalPrice;
  final String fullName;
  final String email;

  final String? pidx;
  final String? transactionId;
  final String? paymentUrl;

  final String paymentMethod;
  final String paymentStatus;
  final String? khaltiStatus;

  PaymentApiModel({
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

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      paymentId: json['_id'],
      bookingId: json['bookingId'] ?? '',
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      pidx: json['pidx'],
      transactionId: json['transactionId'],
      paymentUrl: json['payment_url'], // ← Khalti returns payment_url
      paymentMethod: json['paymentMethod'] ?? 'online',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      khaltiStatus: json['khaltiStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'totalPrice': totalPrice,
      'fullName': fullName,
      'email': email,
      'pidx': pidx,
      'transactionId': transactionId,
      'payment_url': paymentUrl,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'khaltiStatus': khaltiStatus,
    };
  }

  // toEntity
  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      bookingId: bookingId,
      totalPrice: totalPrice,
      fullName: fullName,
      email: email,
      pidx: pidx,
      transactionId: transactionId,
      paymentUrl: paymentUrl,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      khaltiStatus: khaltiStatus,
    );
  }

  // fromEntity
  factory PaymentApiModel.fromEntity(PaymentEntity entity) {
    return PaymentApiModel(
      paymentId: entity.paymentId,
      bookingId: entity.bookingId,
      totalPrice: entity.totalPrice,
      fullName: entity.fullName,
      email: entity.email,
      pidx: entity.pidx,
      transactionId: entity.transactionId,
      paymentUrl: entity.paymentUrl,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      khaltiStatus: entity.khaltiStatus,
    );
  }

  static List<PaymentEntity> toEntityList(List<PaymentApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
