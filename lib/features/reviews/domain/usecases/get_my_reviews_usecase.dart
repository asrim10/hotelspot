import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

final getMyReviewsUsecaseProvider = Provider<GetMyReviewsUsecase>((ref) {
  return GetMyReviewsUsecase(
    reviewRepository: ref.read(reviewRepositoryProvider),
  );
});

class GetMyReviewsUsecase implements UsecaseWithoutParams<List<ReviewEntity>> {
  final IReviewRepository _reviewRepository;
  GetMyReviewsUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, List<ReviewEntity>>> call() {
    return _reviewRepository.getMyReviews();
  }
}
