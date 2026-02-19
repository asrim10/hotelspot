import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String? bookingId;
  final String userId;
  final String hotelId;

  final String fullName;
  final String email;

  final String checkInDate;
  final String checkOutDate;

  final double totalPrice;

  final String? paymentMethod; // cash / card / online
  final String? paymentStatus; // pending / paid / failed

  final String
  status; // pending / confirmed / cancelled / checked_in / checked_out

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    this.bookingId,
    required this.userId,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    this.paymentMethod,
    this.paymentStatus,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    bookingId,
    userId,
    hotelId,
    fullName,
    email,
    checkInDate,
    checkOutDate,
    totalPrice,
    paymentMethod,
    paymentStatus,
    status,
    createdAt,
    updatedAt,
  ];
}
