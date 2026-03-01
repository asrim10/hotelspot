import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? reviewId;
  final String userId;
  final String hotelId;
  final String fullName;
  final String email;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    this.reviewId,
    required this.userId,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    reviewId,
    userId,
    hotelId,
    fullName,
    email,
    rating,
    comment,
    createdAt,
    updatedAt,
  ];
}
