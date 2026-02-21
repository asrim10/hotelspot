import 'package:hive/hive.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:uuid/uuid.dart';

part 'favourite_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.favouriteId)
class FavouriteHiveModel {
  @HiveField(0)
  final String favouriteId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String hotelId;

  @HiveField(3)
  final DateTime? createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  FavouriteHiveModel({
    String? favouriteId,
    required this.userId,
    required this.hotelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : favouriteId = favouriteId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  FavouriteEntity toEntity() {
    return FavouriteEntity(
      favouriteId: favouriteId,
      userId: userId,
      hotelId: hotelId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FavouriteHiveModel.fromEntity(FavouriteEntity entity) {
    return FavouriteHiveModel(
      favouriteId: entity.favouriteId,
      userId: entity.userId,
      hotelId: entity.hotelId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  FavouriteHiveModel copyWith({
    String? favouriteId,
    String? userId,
    String? hotelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavouriteHiveModel(
      favouriteId: favouriteId ?? this.favouriteId,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static List<FavouriteEntity> toEntityList(List<FavouriteHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
