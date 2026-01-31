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
  Future<bool> createHotel(Map<String, dynamic> hotelData) async {
    try {
      final token = _tokenService.getToken();

      print('=== CREATE HOTEL DEBUG ===');
      print('Raw hotelData received: $hotelData');

      // Prepare imageUrl
      String? imageUrl;
      if (hotelData['imageUrl'] != null &&
          hotelData['imageUrl'].toString().isNotEmpty) {
        imageUrl = hotelData['imageUrl'].toString();
        print('ImageUrl found: $imageUrl');
      } else {
        print('ImageUrl is NULL or EMPTY in hotelData');
      }

      // Send as JSON, NOT FormData
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
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };

      print('Final data being sent to backend: $data');
      print('========================');

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

      print('Hotel creation response: ${response.data}');
      return response.data['success'] == true;
    } catch (e) {
      print('Error creating hotel: $e');
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
      }
      rethrow;
    }
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
  @override
  Future<String> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      // Get token
      final token = _tokenService.getToken();

      print('Uploading image: $fileName');

      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadImage,
        formData: formData,
        options: Options(headers: {'Authorization': "Bearer $token"}),
      );

      print('Upload image full response: ${response.data}');

      // Backend returns: { success: true, message: "...", data: {imageUrl: "/uploads/images/..."} }
      if (response.data['data'] != null) {
        final data = response.data['data'];

        // FIXED: Extract imageUrl from the Map
        if (data is Map) {
          final imageUrl = data['imageUrl'];
          if (imageUrl != null) {
            print('Extracted imageUrl: $imageUrl');
            return imageUrl.toString();
          }
        }

        // If data is a string
        if (data is String) {
          print('ImageUrl as string: $data');
          return data;
        }
      }

      // Fallback
      throw Exception('Could not extract imageUrl from upload response');
    } catch (e) {
      print('Error uploading image: $e');
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
      }
      rethrow;
    }
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
