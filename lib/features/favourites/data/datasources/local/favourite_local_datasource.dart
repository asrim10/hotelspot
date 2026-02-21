import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/hive/hive_service.dart';
import 'package:hotelspot/features/favourites/data/datasources/favourite_datasource.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_hive_model.dart';

final favouriteLocalDatasourceProvider = Provider<IFavouriteLocalDataSource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return FavouriteLocalDatasource(hiveService: hiveService);
});

class FavouriteLocalDatasource implements IFavouriteLocalDataSource {
  final HiveService _hiveService;

  FavouriteLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<FavouriteHiveModel> addToFavourites(
    FavouriteHiveModel favourite,
  ) async {
    try {
      return await _hiveService.addToFavourites(favourite);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FavouriteHiveModel>> getMyFavourites(String userId) async {
    try {
      return await _hiveService.getMyFavourites(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> removeFromFavourites(String favouriteId) async {
    try {
      return await _hiveService.removeFromFavourites(favouriteId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeByHotelId(String userId, String hotelId) async {
    try {
      return await _hiveService.removeByHotelId(userId, hotelId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isHotelFavourited(String userId, String hotelId) async {
    try {
      return _hiveService.isHotelFavourited(userId, hotelId);
    } catch (e) {
      return false;
    }
  }
}
