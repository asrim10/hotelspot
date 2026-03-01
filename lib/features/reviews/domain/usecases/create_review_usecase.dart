import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

class CreateReviewParams extends Equatable {
  final String hotelId;
  final double rating;
  final String comment;

  const CreateReviewParams({
    required this.hotelId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [hotelId, rating, comment];
}

final createReviewUsecaseProvider = Provider<CreateReviewUsecase>((ref) {
  return CreateReviewUsecase(
    reviewRepository: ref.read(reviewRepositoryProvider),
  );
});

class CreateReviewUsecase
    implements UsecaseWithParams<bool, CreateReviewParams> {
  final IReviewRepository _reviewRepository;
  CreateReviewUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, bool>> call(CreateReviewParams params) {
    final entity = ReviewEntity(
      userId: '',
      hotelId: params.hotelId,
      fullName: '',
      email: '',
      rating: params.rating,
      comment: params.comment,
    );
    return _reviewRepository.createReview(entity);
  }
}
