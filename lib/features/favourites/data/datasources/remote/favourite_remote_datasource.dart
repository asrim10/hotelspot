import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/favourites/data/datasources/favourite_datasource.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_api_model.dart';

final favouriteRemoteDatasourceProvider = Provider<IFavouriteRemoteDataSource>((
  ref,
) {
  return FavouriteRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class FavouriteRemoteDatasource implements IFavouriteRemoteDataSource {
  final ApiClient _apiClient;

  FavouriteRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<FavouriteApiModel> addToFavourites(FavouriteApiModel favourite) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addFavourite(),
        data: favourite.toJson(),
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return FavouriteApiModel.fromJson(data);
      }

      throw Exception(response.data["message"] ?? "Failed to add favourite");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Network error: ${e.message}",
      );
    }
  }

  @override
  Future<List<FavouriteApiModel>> getMyFavourites(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myFavourites);

      if (response.data["success"] == true) {
        final data = response.data["data"] as List;
        return data
            .map(
              (json) =>
                  FavouriteApiModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Network error: ${e.message}",
      );
    }
  }

  @override
  Future<bool> removeFromFavourites(String favouriteId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.removeFavourite(favouriteId),
      );
      return response.data["success"] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Network error: ${e.message}",
      );
    }
  }

  @override
  Future<bool> removeByHotelId(String hotelId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.favouriteById(hotelId),
      );
      return response.data["success"] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Network error: ${e.message}",
      );
    }
  }

  @override
  Future<bool> isHotelFavourited(String hotelId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.favouriteById(hotelId),
      );
      return response.data["success"] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Network error: ${e.message}",
      );
    }
  }
}
