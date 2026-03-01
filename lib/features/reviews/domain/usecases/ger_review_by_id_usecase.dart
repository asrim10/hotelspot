import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

class GetReviewByIdParams extends Equatable {
  final String reviewId;
  const GetReviewByIdParams({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

final getReviewByIdUsecaseProvider = Provider<GetReviewByIdUsecase>((ref) {
  return GetReviewByIdUsecase(
    reviewRepository: ref.read(reviewRepositoryProvider),
  );
});

class GetReviewByIdUsecase
    implements UsecaseWithParams<ReviewEntity, GetReviewByIdParams> {
  final IReviewRepository _reviewRepository;
  GetReviewByIdUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, ReviewEntity>> call(GetReviewByIdParams params) {
    return _reviewRepository.getReviewById(params.reviewId);
  }
}
