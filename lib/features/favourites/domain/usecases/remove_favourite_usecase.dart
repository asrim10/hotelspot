import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/favourites/data/repositories/favourite_repository.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

class RemoveFavouriteParams extends Equatable {
  final String favouriteId;

  const RemoveFavouriteParams({required this.favouriteId});

  @override
  List<Object?> get props => [favouriteId];
}

final removeFavouriteUsecaseProvider = Provider<RemoveFavouriteUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return RemoveFavouriteUsecase(favouriteRepository: repository);
});

class RemoveFavouriteUsecase
    implements UsecaseWithParams<bool, RemoveFavouriteParams> {
  final IFavouriteRepository _favouriteRepository;

  RemoveFavouriteUsecase({required IFavouriteRepository favouriteRepository})
    : _favouriteRepository = favouriteRepository;

  @override
  Future<Either<Failure, bool>> call(RemoveFavouriteParams params) {
    return _favouriteRepository.removeFromFavourites(params.favouriteId);
  }
}
