import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

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
    );
  }

  //toEntityList
  static List<HotelEntity> toEntityList(List<HotelApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
