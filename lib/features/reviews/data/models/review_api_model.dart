import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';

class ReviewApiModel {
  final String id;
  final String userId;
  final String hotelId;
  final String fullName;
  final String email;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewApiModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    final userField = json['userId'];
    final String parsedUserId = userField is Map
        ? (userField['_id'] ?? '').toString()
        : (userField ?? '').toString();

    final hotelField = json['hotelId'];
    final String parsedHotelId = hotelField is Map
        ? (hotelField['_id'] ?? '').toString()
        : (hotelField ?? '').toString();

    return ReviewApiModel(
      id: json['_id'],
      userId: parsedUserId,
      hotelId: parsedHotelId,
      fullName: json['fullName'],
      email: json['email'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'hotelId': hotelId,
    'rating': rating,
    'comment': comment,
  };

  ReviewEntity toEntity() => ReviewEntity(
    reviewId: id,
    userId: userId,
    hotelId: hotelId,
    fullName: fullName,
    email: email,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory ReviewApiModel.fromEntity(ReviewEntity entity) => ReviewApiModel(
    id: entity.reviewId ?? '',
    userId: entity.userId,
    hotelId: entity.hotelId,
    fullName: entity.fullName,
    email: entity.email,
    rating: entity.rating,
    comment: entity.comment,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  static List<ReviewEntity> toEntityList(List<ReviewApiModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
