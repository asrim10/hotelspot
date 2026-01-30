import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/features/hotel/data/hotel_datasource.dart';

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
  Future<void> createHotel(Map<String, dynamic> hotelData) {
    final token = _tokenService.getToken();
    return _apiClient.post(
      ApiEndpoints.createHotel(),
      data: hotelData,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
  }

  @override
  Future<void> deleteHotel(String hotelId) {
    final token = _tokenService.getToken();
    return _apiClient.delete(
      ApiEndpoints.deleteHotel(hotelId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllHotels() {
    return _apiClient.get(ApiEndpoints.hotels).then((response) {
      final data = response.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    });
  }

  @override
  Future<Map<String, dynamic>> getHotelById(String hotelId) {
    return _apiClient
        .get(ApiEndpoints.hotelById(hotelId))
        .then((response) => response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateHotel(String hotelId, Map<String, dynamic> hotelData) {
    final token = _tokenService.getToken();
    return _apiClient.put(
      ApiEndpoints.updateHotel(hotelId),
      data: hotelData,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
  }

  @override
  Future<String> uploadImage(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'image': MultipartFile.fromFile(image.path, filename: fileName),
    });
    //get token
    final token = _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadImage,
      formData: formData,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    return response.data['success'];
  }

  @override
  Future<String> uploadVideo(File video) async {
    final fileName = video.path.split('/').last;
    final formData = FormData.fromMap({
      'video': MultipartFile.fromFile(video.path, filename: fileName),
    });
    //get token
    final token = _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadVideo,
      formData: formData,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    return response.data['success'];
  }
}
