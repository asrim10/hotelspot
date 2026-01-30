import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

class HotelApiModel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String? description;
  final String? image;
  final String? video;

  HotelApiModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    this.description,
    this.image,
    this.video,
  });

  factory HotelApiModel.fromJson(Map<String, dynamic> json) {
    return HotelApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String?,
      image: json['image'] as String?,
      video: json['video'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'description': description,
      'image': image,
      'video': video,
    };
  }

  HotelEntity toEntity() {
    return HotelEntity(
      hotelId: id,
      name: name,
      location: location,
      rating: rating,
      description: description,
      image: image,
      video: video,
    );
  }

  factory HotelApiModel.fromEntity(HotelEntity entity) {
    return HotelApiModel(
      id: entity.hotelId,
      name: entity.name,
      location: entity.location,
      rating: entity.rating,
      description: entity.description,
      image: entity.image,
      video: entity.video,
    );
  }

  //toEntityList
  static List<HotelEntity> toEntityList(List<HotelApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
