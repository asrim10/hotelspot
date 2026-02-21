// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavouriteApiModel _$FavouriteApiModelFromJson(Map<String, dynamic> json) =>
    FavouriteApiModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      hotelId: json['hotelId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FavouriteApiModelToJson(FavouriteApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'hotelId': instance.hotelId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
