// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentApiModel _$PaymentApiModelFromJson(Map<String, dynamic> json) =>
    PaymentApiModel(
      paymentId: json['paymentId'] as String?,
      bookingId: json['bookingId'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      pidx: json['pidx'] as String?,
      transactionId: json['transactionId'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'online',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      khaltiStatus: json['khaltiStatus'] as String?,
    );

Map<String, dynamic> _$PaymentApiModelToJson(PaymentApiModel instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'bookingId': instance.bookingId,
      'totalPrice': instance.totalPrice,
      'fullName': instance.fullName,
      'email': instance.email,
      'pidx': instance.pidx,
      'transactionId': instance.transactionId,
      'paymentUrl': instance.paymentUrl,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'khaltiStatus': instance.khaltiStatus,
    };
