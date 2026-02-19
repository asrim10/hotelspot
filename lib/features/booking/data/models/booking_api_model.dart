import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_api_model.g.dart';

@JsonSerializable()
class BookingApiModel {
  final String? id;
  final String userId;
  final String hotelId;

  final String fullName;
  final String email;

  final String checkInDate;
  final String checkOutDate;

  final double totalPrice;

  final String? paymentMethod;
  final String? paymentStatus;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingApiModel({
    this.id,
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

  // From JSON (API response) -> Model
  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    return BookingApiModel(
      id: json["_id"] as String?,
      userId: json["userId"] as String,
      hotelId: json["hotelId"] as String,
      fullName: json["fullName"] as String,
      email: json["email"] as String,
      checkInDate: json["checkInDate"] as String,
      checkOutDate: json["checkOutDate"] as String,
      totalPrice: (json["totalPrice"] as num).toDouble(),
      paymentMethod: json["paymentMethod"] as String?,
      paymentStatus: json["paymentStatus"] as String?,
      status: json["status"] as String,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "hotelId": hotelId,
      "fullName": fullName,
      "email": email,
      "checkInDate": checkInDate,
      "checkOutDate": checkOutDate,
      "totalPrice": totalPrice,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "status": status,
    };
  }

  // Convert to Entity
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: id,
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

  // From Entity -> Model
  factory BookingApiModel.fromEntity(BookingEntity entity) {
    return BookingApiModel(
      id: entity.bookingId,
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

  // Convert List of Models -> List of Entities
  static List<BookingEntity> toEntityList(List<BookingApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
