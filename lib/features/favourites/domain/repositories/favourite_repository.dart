import 'package:dartz/dartz.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';

abstract interface class IFavouriteRepository {
  Future<Either<Failure, FavouriteEntity>> addToFavourites(
    FavouriteEntity favourite,
  );
  Future<Either<Failure, List<FavouriteEntity>>> getMyFavourites(String userId);
  Future<Either<Failure, bool>> removeFromFavourites(String favouriteId);
  Future<Either<Failure, bool>> removeByHotelId(String userId, String hotelId);
  Future<Either<Failure, bool>> isHotelFavourited(
    String userId,
    String hotelId,
  );
}
