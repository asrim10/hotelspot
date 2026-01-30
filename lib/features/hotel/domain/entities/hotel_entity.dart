import 'dart:io';

import 'package:equatable/equatable.dart';

class HotelEntity extends Equatable {
  final String hotelId;
  final String name;
  final String location;
  final double rating;
  final String? description;
  final File? image;
  final File? video;

  HotelEntity({
    required this.hotelId,
    required this.name,
    required this.location,
    required this.rating,
    this.description,
    this.image,
    this.video,
  });

  @override
  List<Object?> get props => [
    hotelId,
    name,
    location,
    rating,
    description,
    image,
    video,
  ];
}
