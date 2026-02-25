import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_api_model.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

part 'hotel_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.hotelId)
class HotelHiveModel extends HiveObject {
  @HiveField(0)
  final String hotelId;

  @HiveField(1)
  final String hotelName;

  @HiveField(2)
  final String city;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String country;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final int availableRooms;

  @HiveField(7)
  final double rating;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final double? coordinateLat;

  @HiveField(11)
  final double? coordinateLng;

  HotelHiveModel({
    String? hotelId,
    required this.hotelName,
    required this.city,
    required this.price,
    required this.country,
    required this.address,
    required this.availableRooms,
    required this.rating,
    this.description,
    this.imageUrl,
    this.coordinateLat,
    this.coordinateLng,
  }) : hotelId = hotelId ?? const Uuid().v4();

  HotelEntity toEntity() {
    return HotelEntity(
      hotelId: hotelId,
      hotelName: hotelName,
      city: city,
      price: price,
      country: country,
      address: address,
      availableRooms: availableRooms,
      rating: rating,
      description: description,
      imageUrl: imageUrl,
      coordinates: (coordinateLat != null && coordinateLng != null)
          ? {'lat': coordinateLat!, 'lng': coordinateLng!}
          : null,
    );
  }

  factory HotelHiveModel.fromEntity(HotelEntity entity) {
    return HotelHiveModel(
      hotelId: entity.hotelId,
      hotelName: entity.hotelName,
      city: entity.city,
      price: entity.price,
      country: entity.country,
      address: entity.address,
      availableRooms: entity.availableRooms,
      rating: entity.rating,
      description: entity.description,
      imageUrl: entity.imageUrl,
      coordinateLat: entity.coordinates?['lat'],
      coordinateLng: entity.coordinates?['lng'],
    );
  }

  static List<HotelEntity> toEntityList(List<HotelHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  factory HotelHiveModel.fromApiModel(HotelApiModel apiModel) {
    return HotelHiveModel(
      hotelId: apiModel.id,
      hotelName: apiModel.hotelName,
      city: apiModel.city,
      price: apiModel.price,
      country: apiModel.country,
      address: apiModel.address,
      availableRooms: apiModel.availableRooms,
      rating: apiModel.rating ?? 0.0,
      description: apiModel.description,
      imageUrl: apiModel.imageUrl,
      coordinateLat: apiModel.coordinates?.lat,
      coordinateLng: apiModel.coordinates?.lng,
    );
  }

  static List<HotelHiveModel> fromApiModelList(List<HotelApiModel> apiModels) {
    return apiModels
        .map((model) => HotelHiveModel.fromApiModel(model))
        .toList();
  }
}
