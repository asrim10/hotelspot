import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/favourites/data/repositories/favourite_repository.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

class GetMyFavouritesParams extends Equatable {
  final String userId;

  const GetMyFavouritesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getMyFavouritesUsecaseProvider = Provider<GetMyFavouritesUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return GetMyFavouritesUsecase(favouriteRepository: repository);
});

class GetMyFavouritesUsecase
    implements UsecaseWithParams<List<FavouriteEntity>, GetMyFavouritesParams> {
  final IFavouriteRepository _favouriteRepository;

  GetMyFavouritesUsecase({required IFavouriteRepository favouriteRepository})
    : _favouriteRepository = favouriteRepository;

  @override
  Future<Either<Failure, List<FavouriteEntity>>> call(
    GetMyFavouritesParams params,
  ) {
    return _favouriteRepository.getMyFavourites(params.userId);
  }
}
