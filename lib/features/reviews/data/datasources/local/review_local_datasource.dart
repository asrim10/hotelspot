import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/hive/hive_service.dart';
import 'package:hotelspot/features/reviews/data/datasources/review_datasource.dart';
import 'package:hotelspot/features/reviews/data/models/review_hive_model.dart';

final reviewLocalDatasourceProvider = Provider<IReviewLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ReviewLocalDatasource(hiveService: hiveService);
});

class ReviewLocalDatasource implements IReviewLocalDatasource {
  final HiveService _hiveService;

  ReviewLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> cacheReviewsByHotelId(
    String hotelId,
    List<ReviewHiveModel> reviews,
  ) async {
    try {
      await _hiveService.clearReviewsByHotelId(hotelId);
      for (final review in reviews) {
        await _hiveService.saveReview(review);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ReviewHiveModel>> getReviewsByHotelId(String hotelId) async {
    try {
      return await _hiveService.getReviewsByHotelId(hotelId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ReviewHiveModel>> getMyReviews(String userId) async {
    try {
      return await _hiveService.getMyReviews(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ReviewHiveModel?> getReviewById(String reviewId) async {
    try {
      return _hiveService.getReviewById(reviewId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveReview(ReviewHiveModel review) async {
    try {
      await _hiveService.saveReview(review);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateReview(ReviewHiveModel review) async {
    try {
      await _hiveService.updateReview(review);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      return await _hiveService.deleteReview(reviewId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearAllReviews() async {
    try {
      await _hiveService.clearAllReviews();
      return true;
    } catch (e) {
      return false;
    }
  }
}
