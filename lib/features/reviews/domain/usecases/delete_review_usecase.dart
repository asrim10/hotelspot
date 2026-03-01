import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

class DeleteReviewParams extends Equatable {
  final String reviewId;
  const DeleteReviewParams({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

final deleteReviewUsecaseProvider = Provider<DeleteReviewUsecase>((ref) {
  return DeleteReviewUsecase(
    reviewRepository: ref.read(reviewRepositoryProvider),
  );
});

class DeleteReviewUsecase
    implements UsecaseWithParams<bool, DeleteReviewParams> {
  final IReviewRepository _reviewRepository;
  DeleteReviewUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteReviewParams params) {
    return _reviewRepository.deleteReview(params.reviewId);
  }
}
