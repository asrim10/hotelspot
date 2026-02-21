import 'package:equatable/equatable.dart';

class FavouriteEntity extends Equatable {
  final String? favouriteId;
  final String userId;
  final String hotelId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FavouriteEntity({
    this.favouriteId,
    required this.userId,
    required this.hotelId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    favouriteId,
    userId,
    hotelId,
    createdAt,
    updatedAt,
  ];
}
