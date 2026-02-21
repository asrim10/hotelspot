import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'favourite_api_model.g.dart';

@JsonSerializable()
class FavouriteApiModel {
  final String? id;
  final String userId;
  final String hotelId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  FavouriteApiModel({
    this.id,
    required this.userId,
    required this.hotelId,
    this.createdAt,
    this.updatedAt,
  });

  factory FavouriteApiModel.fromJson(Map<String, dynamic> json) {
    return FavouriteApiModel(
      id: json["_id"] as String?,
      userId: json["userId"] as String,
      hotelId: json["hotelId"] as String,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"userId": userId, "hotelId": hotelId};
  }

  FavouriteEntity toEntity() {
    return FavouriteEntity(
      favouriteId: id,
      userId: userId,
      hotelId: hotelId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FavouriteApiModel.fromEntity(FavouriteEntity entity) {
    return FavouriteApiModel(
      id: entity.favouriteId,
      userId: entity.userId,
      hotelId: entity.hotelId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<FavouriteEntity> toEntityList(List<FavouriteApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
