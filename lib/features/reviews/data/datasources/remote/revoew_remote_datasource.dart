import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/features/reviews/data/datasources/review_datasource.dart';
import 'package:hotelspot/features/reviews/data/models/review_api_model.dart';

final reviewRemoteDatasourceProvider = Provider<IReviewRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return ReviewRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class ReviewRemoteDatasource implements IReviewRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ReviewRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Options get _authOptions =>
      Options(headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'});

  @override
  Future<List<ReviewApiModel>> getReviewsByHotelId(String hotelId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.reviewsByHotelId(hotelId),
      );
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => ReviewApiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<List<ReviewApiModel>> getMyReviews() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.myReviews,
        options: _authOptions,
      );
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => ReviewApiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<ReviewApiModel> getReviewById(String reviewId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.reviewById(reviewId),
        options: _authOptions,
      );
      return ReviewApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<bool> createReview(Map<String, dynamic> reviewData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createReview(),
        data: {
          'hotelId': reviewData['hotelId'],
          'rating': reviewData['rating'],
          'comment': reviewData['comment'],
        },
        options: _authOptions,
      );
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateReview(
    String reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateReview(reviewId),
        data: {
          if (reviewData['rating'] != null) 'rating': reviewData['rating'],
          if (reviewData['comment'] != null) 'comment': reviewData['comment'],
        },
        options: _authOptions,
      );
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.deleteReview(reviewId),
        options: _authOptions,
      );
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }
}
