// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelApiModel _$HotelApiModelFromJson(Map<String, dynamic> json) =>
    HotelApiModel(
      id: json['id'] as String,
      hotelName: json['hotelName'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      price: (json['price'] as num).toDouble(),
      availableRooms: (json['availableRooms'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$HotelApiModelToJson(HotelApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotelName': instance.hotelName,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'price': instance.price,
      'availableRooms': instance.availableRooms,
      'rating': instance.rating,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };
