import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/features/hotel/data/hotel_datasource.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_api_model.dart';

final hotelRemoteDatasourceProvider = Provider<IHotelRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return HotelRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class HotelRemoteDatasource implements IHotelRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  HotelRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<bool> createHotel(Map<String, dynamic> hotelData) async {
    try {
      final token = _tokenService.getToken();

      final data = {
        'hotelName': hotelData['hotelName'],
        'address': hotelData['address'],
        'city': hotelData['city'],
        'country': hotelData['country'],
        'rating': hotelData['rating'],
        'price': hotelData['price'],
        'availableRooms': hotelData['availableRooms'],
        if (hotelData['description'] != null &&
            hotelData['description'].toString().isNotEmpty)
          'description': hotelData['description'],
        if (hotelData['imageUrl'] != null &&
            hotelData['imageUrl'].toString().isNotEmpty)
          'imageUrl': hotelData['imageUrl'],
      };

      final response = await _apiClient.post(
        ApiEndpoints.createHotel(),
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
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
  Future<bool> deleteHotel(String hotelId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteHotel(hotelId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['success'] == true;
  }

  @override
  Future<List<HotelApiModel>> getAllHotels() async {
    final response = await _apiClient.get(ApiEndpoints.hotels);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => HotelApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HotelApiModel> getHotelById(String hotelId) async {
    final response = await _apiClient.get(ApiEndpoints.hotelById(hotelId));
    return HotelApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<bool> updateHotel(
    String hotelId,
    Map<String, dynamic> hotelData,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.put(
      ApiEndpoints.updateHotel(hotelId),
      data: hotelData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['success'] == true;
  }

  @override
  Future<String> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final token = _tokenService.getToken();

      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadImage,
        formData: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data['data'];

      if (data is Map) {
        final imageUrl = data['imageUrl'];
        if (imageUrl != null) return imageUrl.toString();
      }

      if (data is String) return data;

      throw Exception('Could not extract imageUrl from upload response');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadVideo(File video) async {
    try {
      final fileName = video.path.split('/').last;
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(video.path, filename: fileName),
      });

      final token = _tokenService.getToken();

      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadVideo,
        formData: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data['data'];

      if (data is Map) {
        final videoUrl = data['videoUrl'];
        if (videoUrl != null) return videoUrl.toString();
      }

      if (data is String) return data;

      throw Exception('Could not extract videoUrl from upload response');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.message);
      }
      rethrow;
    }
  }
}
