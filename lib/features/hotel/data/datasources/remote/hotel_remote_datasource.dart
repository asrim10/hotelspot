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
  @override
  Future<bool> createHotel(Map<String, dynamic> hotelData) async {
    final token = _tokenService.getToken();

    final formData = FormData.fromMap({
      'hotelName': hotelData['hotelName'],
      'address': hotelData['address'],
      'city': hotelData['city'],
      'country': hotelData['country'],
      'rating': hotelData['rating']?.toString(),
      'description': hotelData['description'],
      'price': hotelData['price'].toString(),
      'availableRooms': hotelData['availableRooms'].toString(),
      if (hotelData['image'] != null)
        'image': await MultipartFile.fromFile(
          hotelData['image'].path,
          filename: hotelData['image'].path.split('/').last,
        ),
    });

    final response = await _apiClient.post(
      ApiEndpoints.createHotel(),
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    return response.data['success'] == true;
  }

  @override
  Future<bool> deleteHotel(String hotelId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteHotel(hotelId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    return response.data['success'];
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
  Future<bool> updateHotel(
    String hotelId,
    Map<String, dynamic> hotelData,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.put(
      ApiEndpoints.updateHotel(hotelId),
      data: hotelData,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    return response.data['success'];
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
    return response.data['data'];
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
