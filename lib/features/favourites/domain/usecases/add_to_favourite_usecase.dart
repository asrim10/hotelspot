import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/favourites/data/repositories/favourite_repository.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

class AddToFavouritesParams extends Equatable {
  final String userId;
  final String hotelId;

  const AddToFavouritesParams({required this.userId, required this.hotelId});

  @override
  List<Object?> get props => [userId, hotelId];
}

final addToFavouritesUsecaseProvider = Provider<AddToFavouritesUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return AddToFavouritesUsecase(favouriteRepository: repository);
});

class AddToFavouritesUsecase
    implements UsecaseWithParams<FavouriteEntity, AddToFavouritesParams> {
  final IFavouriteRepository _favouriteRepository;

  AddToFavouritesUsecase({required IFavouriteRepository favouriteRepository})
    : _favouriteRepository = favouriteRepository;

  @override
  Future<Either<Failure, FavouriteEntity>> call(AddToFavouritesParams params) {
    final favEntity = FavouriteEntity(
      favouriteId: null,
      userId: params.userId,
      hotelId: params.hotelId,
    );

    return _favouriteRepository.addToFavourites(favEntity);
  }
}
