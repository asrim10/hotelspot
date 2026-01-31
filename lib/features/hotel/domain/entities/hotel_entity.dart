import 'package:equatable/equatable.dart';

class HotelEntity extends Equatable {
  final String? hotelId;
  final String hotelName;
  final String city;
  final double price;
  final String country;
  final String address;
  final int availableRooms;
  final double rating;
  final String? description;
  final String? imageUrl;

  const HotelEntity({
    this.hotelId,
    required this.hotelName,
    required this.city,
    required this.price,
    required this.country,
    required this.address,
    required this.availableRooms,
    required this.rating,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    hotelId,
    hotelName,
    city,
    price,
    country,
    address,
    availableRooms,
    rating,
    description,
    imageUrl,
  ];
}
