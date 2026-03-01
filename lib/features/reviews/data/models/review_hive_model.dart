import 'package:hive/hive.dart';
import 'package:hotelspot/features/reviews/data/models/review_api_model.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';

part 'review_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.reviewId)
class ReviewHiveModel extends HiveObject {
  @HiveField(0)
  final String reviewId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String hotelId;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final double rating;

  @HiveField(6)
  final String comment;

  @HiveField(7)
  final DateTime? createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  ReviewHiveModel({
    String? reviewId,
    required this.userId,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  }) : reviewId = reviewId ?? const Uuid().v4();

  ReviewEntity toEntity() => ReviewEntity(
    reviewId: reviewId,
    userId: userId,
    hotelId: hotelId,
    fullName: fullName,
    email: email,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory ReviewHiveModel.fromEntity(ReviewEntity entity) => ReviewHiveModel(
    reviewId: entity.reviewId,
    userId: entity.userId,
    hotelId: entity.hotelId,
    fullName: entity.fullName,
    email: entity.email,
    rating: entity.rating,
    comment: entity.comment,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  factory ReviewHiveModel.fromApiModel(ReviewApiModel apiModel) =>
      ReviewHiveModel(
        reviewId: apiModel.id,
        userId: apiModel.userId,
        hotelId: apiModel.hotelId,
        fullName: apiModel.fullName,
        email: apiModel.email,
        rating: apiModel.rating,
        comment: apiModel.comment,
        createdAt: apiModel.createdAt,
        updatedAt: apiModel.updatedAt,
      );

  static List<ReviewEntity> toEntityList(List<ReviewHiveModel> models) =>
      models.map((m) => m.toEntity()).toList();

  static List<ReviewHiveModel> fromApiModelList(
    List<ReviewApiModel> apiModels,
  ) => apiModels.map((m) => ReviewHiveModel.fromApiModel(m)).toList();
}
