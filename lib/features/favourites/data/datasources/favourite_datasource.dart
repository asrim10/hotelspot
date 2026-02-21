import 'package:hotelspot/features/favourites/data/models/favourite_api_model.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_hive_model.dart';

abstract interface class IFavouriteLocalDataSource {
  Future<FavouriteHiveModel> addToFavourites(FavouriteHiveModel favourite);
  Future<List<FavouriteHiveModel>> getMyFavourites(String userId);
  Future<bool> removeFromFavourites(String favouriteId);
  Future<bool> removeByHotelId(String userId, String hotelId);
  Future<bool> isHotelFavourited(String userId, String hotelId);
}

abstract interface class IFavouriteRemoteDataSource {
  Future<FavouriteApiModel> addToFavourites(FavouriteApiModel favourite);
  Future<List<FavouriteApiModel>> getMyFavourites(String userId);
  Future<bool> removeFromFavourites(String favouriteId);
  Future<bool> removeByHotelId(String hotelId);
  Future<bool> isHotelFavourited(String hotelId);
}
