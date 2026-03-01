import 'package:hotelspot/features/reviews/data/models/review_api_model.dart';
import 'package:hotelspot/features/reviews/data/models/review_hive_model.dart';

abstract interface class IReviewLocalDatasource {
  Future<bool> cacheReviewsByHotelId(
    String hotelId,
    List<ReviewHiveModel> reviews,
  );
  Future<List<ReviewHiveModel>> getReviewsByHotelId(String hotelId);
  Future<List<ReviewHiveModel>> getMyReviews(String userId);
  Future<ReviewHiveModel?> getReviewById(String reviewId);
  Future<bool> saveReview(ReviewHiveModel review);
  Future<bool> updateReview(ReviewHiveModel review);
  Future<bool> deleteReview(String reviewId);
  Future<bool> clearAllReviews();
}

abstract interface class IReviewRemoteDatasource {
  Future<List<ReviewApiModel>> getReviewsByHotelId(String hotelId);
  Future<List<ReviewApiModel>> getMyReviews();
  Future<ReviewApiModel> getReviewById(String reviewId);
  Future<bool> createReview(Map<String, dynamic> reviewData);
  Future<bool> updateReview(String reviewId, Map<String, dynamic> reviewData);
  Future<bool> deleteReview(String reviewId);
}
