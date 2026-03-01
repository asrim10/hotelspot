import 'package:dartz/dartz.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';

abstract interface class IReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByHotelId(
    String hotelId,
  );
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews();
  Future<Either<Failure, ReviewEntity>> getReviewById(String reviewId);
  Future<Either<Failure, bool>> createReview(ReviewEntity review);
  Future<Either<Failure, bool>> updateReview(ReviewEntity review);
  Future<Either<Failure, bool>> deleteReview(String reviewId);
}
