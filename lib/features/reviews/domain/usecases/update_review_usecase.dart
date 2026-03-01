import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

class UpdateReviewParams extends Equatable {
  final String reviewId;
  final String userId;
  final String hotelId;
  final String fullName;
  final String email;
  final double rating;
  final String comment;

  const UpdateReviewParams({
    required this.reviewId,
    required this.userId,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.rating,
    required this.comment,
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
  ];
}

final updateReviewUsecaseProvider = Provider<UpdateReviewUsecase>((ref) {
  return UpdateReviewUsecase(
    reviewRepository: ref.read(reviewRepositoryProvider),
  );
});

class UpdateReviewUsecase
    implements UsecaseWithParams<bool, UpdateReviewParams> {
  final IReviewRepository _reviewRepository;
  UpdateReviewUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateReviewParams params) {
    final entity = ReviewEntity(
      reviewId: params.reviewId,
      userId: params.userId,
      hotelId: params.hotelId,
      fullName: params.fullName,
      email: params.email,
      rating: params.rating,
      comment: params.comment,
    );
    return _reviewRepository.updateReview(entity);
  }
}
