import 'package:hive/hive.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:uuid/uuid.dart';

part 'booking_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.bookingId)
class BookingHiveModel {
  @HiveField(0)
  final String bookingId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String hotelId;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String checkInDate;

  @HiveField(6)
  final String checkOutDate;

  @HiveField(7)
  final double totalPrice;

  @HiveField(8)
  final String? paymentMethod;

  @HiveField(9)
  final String? paymentStatus;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  BookingHiveModel({
    String? bookingId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : bookingId = bookingId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Entity
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: bookingId,
      userId: userId,
      hotelId: hotelId,
      fullName: fullName,
      email: email,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // From Entity
  factory BookingHiveModel.fromEntity(BookingEntity entity) {
    return BookingHiveModel(
      bookingId: entity.bookingId,
      userId: entity.userId,
      hotelId: entity.hotelId,
      fullName: entity.fullName,
      email: entity.email,
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      totalPrice: entity.totalPrice,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Copy with method for updates
  BookingHiveModel copyWith({
    String? bookingId,
    String? userId,
    String? hotelId,
    String? fullName,
    String? email,
    String? checkInDate,
    String? checkOutDate,
    double? totalPrice,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingHiveModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert list of models to entities
  static List<BookingEntity> toEntityList(List<BookingHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
