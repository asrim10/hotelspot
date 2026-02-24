import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hotel_api_model.g.dart';

class CoordinatesModel {
  final double lat;
  final double lng;

  CoordinatesModel({required this.lat, required this.lng});

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

@JsonSerializable()
class HotelApiModel {
  final String id;
  final String hotelName;
  final String address;
  final String city;
  final String country;
  final double price;
  final int availableRooms;
  final double? rating;
  final String? description;
  final String? imageUrl;
  final CoordinatesModel? coordinates; // added

  HotelApiModel({
    required this.id,
    required this.hotelName,
    required this.address,
    required this.city,
    required this.country,
    required this.price,
    required this.availableRooms,
    this.rating,
    this.description,
    this.imageUrl,
    this.coordinates,
  });

  factory HotelApiModel.fromJson(Map<String, dynamic> json) {
    return HotelApiModel(
      id: json['_id'],
      hotelName: json['hotelName'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      price: (json['price'] as num).toDouble(),
      availableRooms: json['availableRooms'],
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      description: json['description'],
      imageUrl: json['imageUrl'],
      coordinates: json['coordinates'] != null
          ? CoordinatesModel.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelName': hotelName,
      'address': address,
      'city': city,
      'country': country,
      'price': price,
      'availableRooms': availableRooms,
      'rating': rating,
      'description': description,
      'imageUrl': imageUrl,
      'coordinates': coordinates?.toJson(),
    };
  }

  HotelEntity toEntity() {
    return HotelEntity(
      hotelId: id,
      hotelName: hotelName,
      city: city,
      price: price,
      country: country,
      address: address,
      availableRooms: availableRooms,
      rating: rating ?? 0.0,
      description: description,
      imageUrl: imageUrl,
      coordinates: coordinates != null
          ? {'lat': coordinates!.lat, 'lng': coordinates!.lng}
          : null,
    );
  }

  factory HotelApiModel.fromEntity(HotelEntity entity) {
    return HotelApiModel(
      id: entity.hotelId!,
      hotelName: entity.hotelName,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      price: entity.price,
      availableRooms: entity.availableRooms,
      rating: entity.rating,
      description: entity.description,
      imageUrl: entity.imageUrl,
      coordinates: entity.coordinates != null
          ? CoordinatesModel(
              lat: entity.coordinates!['lat']!,
              lng: entity.coordinates!['lng']!,
            )
          : null,
    );
  }

  static List<HotelEntity> toEntityList(List<HotelApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
