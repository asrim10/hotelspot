import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/reviews/data/datasources/local/review_local_datasource.dart';
import 'package:hotelspot/features/reviews/data/datasources/remote/revoew_remote_datasource.dart';
import 'package:hotelspot/features/reviews/data/datasources/review_datasource.dart';
import 'package:hotelspot/features/reviews/data/models/review_hive_model.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<IReviewRepository>((ref) {
  final reviewRemoteDatasource = ref.watch(reviewRemoteDatasourceProvider);
  final reviewLocalDatasource = ref.watch(reviewLocalDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ReviewRepository(
    reviewRemoteDatasource: reviewRemoteDatasource,
    reviewLocalDatasource: reviewLocalDatasource,
    networkInfo: networkInfo,
  );
});

class ReviewRepository implements IReviewRepository {
  final IReviewRemoteDatasource _reviewRemoteDatasource;
  final IReviewLocalDatasource _reviewLocalDatasource;
  final NetworkInfo _networkInfo;

  ReviewRepository({
    required IReviewRemoteDatasource reviewRemoteDatasource,
    required IReviewLocalDatasource reviewLocalDatasource,
    required NetworkInfo networkInfo,
  }) : _reviewRemoteDatasource = reviewRemoteDatasource,
       _reviewLocalDatasource = reviewLocalDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByHotelId(
    String hotelId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _reviewRemoteDatasource.getReviewsByHotelId(
          hotelId,
        );
        final reviews = apiModels.map((m) => m.toEntity()).toList();

        final hiveModels = ReviewHiveModel.fromApiModelList(apiModels);
        await _reviewLocalDatasource.cacheReviewsByHotelId(hotelId, hiveModels);

        return Right(reviews);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModels = await _reviewLocalDatasource.getReviewsByHotelId(
          hotelId,
        );
        final reviews = ReviewHiveModel.toEntityList(hiveModels);
        return Right(reviews);
      } catch (e) {
        return Left(ApiFailure(message: 'No internet connection'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _reviewRemoteDatasource.getMyReviews();
        final reviews = apiModels.map((m) => m.toEntity()).toList();
        return Right(reviews);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> getReviewById(String reviewId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _reviewRemoteDatasource.getReviewById(reviewId);
        return Right(apiModel.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final hiveModel = await _reviewLocalDatasource.getReviewById(reviewId);
      if (hiveModel != null) return Right(hiveModel.toEntity());
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> createReview(ReviewEntity review) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _reviewRemoteDatasource.createReview({
          'hotelId': review.hotelId,
          'rating': review.rating,
          'comment': review.comment,
        });
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateReview(ReviewEntity review) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _reviewRemoteDatasource.updateReview(
          review.reviewId!,
          {'rating': review.rating, 'comment': review.comment},
        );

        // Sync to local cache
        if (result) {
          final hiveModel = ReviewHiveModel.fromEntity(review);
          await _reviewLocalDatasource.updateReview(hiveModel);
        }

        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReview(String reviewId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _reviewRemoteDatasource.deleteReview(reviewId);

        if (result) {
          await _reviewLocalDatasource.deleteReview(reviewId);
        }

        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}
