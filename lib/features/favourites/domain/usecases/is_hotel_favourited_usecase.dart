import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/favourites/data/repositories/favourite_repository.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

class IsHotelFavouritedParams extends Equatable {
  final String userId;
  final String hotelId;

  const IsHotelFavouritedParams({required this.userId, required this.hotelId});

  @override
  List<Object?> get props => [userId, hotelId];
}

final isHotelFavouritedUsecaseProvider = Provider<IsHotelFavouritedUsecase>((
  ref,
) {
  final repository = ref.read(favouriteRepositoryProvider);
  return IsHotelFavouritedUsecase(favouriteRepository: repository);
});

class IsHotelFavouritedUsecase
    implements UsecaseWithParams<bool, IsHotelFavouritedParams> {
  final IFavouriteRepository _favouriteRepository;

  IsHotelFavouritedUsecase({required IFavouriteRepository favouriteRepository})
    : _favouriteRepository = favouriteRepository;

  @override
  Future<Either<Failure, bool>> call(IsHotelFavouritedParams params) {
    return _favouriteRepository.isHotelFavourited(
      params.userId,
      params.hotelId,
    );
  }
}
