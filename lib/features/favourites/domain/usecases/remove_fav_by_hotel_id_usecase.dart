import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/favourites/data/repositories/favourite_repository.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

class RemoveByHotelIdParams extends Equatable {
  final String userId;
  final String hotelId;

  const RemoveByHotelIdParams({required this.userId, required this.hotelId});

  @override
  List<Object?> get props => [userId, hotelId];
}

final removeByHotelIdUsecaseProvider = Provider<RemoveByHotelIdUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return RemoveByHotelIdUsecase(favouriteRepository: repository);
});

class RemoveByHotelIdUsecase
    implements UsecaseWithParams<bool, RemoveByHotelIdParams> {
  final IFavouriteRepository _favouriteRepository;

  RemoveByHotelIdUsecase({required IFavouriteRepository favouriteRepository})
    : _favouriteRepository = favouriteRepository;

  @override
  Future<Either<Failure, bool>> call(RemoveByHotelIdParams params) {
    return _favouriteRepository.removeByHotelId(params.userId, params.hotelId);
  }
}
