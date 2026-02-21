import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/usecases/add_to_favourite_usecase.dart';
import 'package:hotelspot/features/favourites/domain/usecases/get_my_favourite_usecase.dart';
import 'package:hotelspot/features/favourites/domain/usecases/remove_favourtie_usecase.dart';
import 'package:hotelspot/features/favourites/presentation/state/favourite_state.dart';

final favouriteViewModelProvider =
    NotifierProvider<FavouriteViewModel, FavouriteState>(
      () => FavouriteViewModel(),
    );

class FavouriteViewModel extends Notifier<FavouriteState> {
  late final AddToFavouritesUsecase _addToFavouritesUsecase;
  late final GetMyFavouritesUsecase _getMyFavouritesUsecase;
  late final RemoveFavouriteUsecase _removeFromFavouritesUsecase;

  @override
  FavouriteState build() {
    _addToFavouritesUsecase = ref.read(addToFavouritesUsecaseProvider);
    _getMyFavouritesUsecase = ref.read(getMyFavouritesUsecaseProvider);
    _removeFromFavouritesUsecase = ref.read(removeFavouriteUsecaseProvider);
    return const FavouriteState();
  }

  // Add to favourites
  Future<void> addToFavourites(FavouriteEntity favourite) async {
    state = state.copyWith(status: FavouriteStatus.adding);

    final result = await _addToFavouritesUsecase(
      AddToFavouritesParams(
        userId: favourite.userId,
        hotelId: favourite.hotelId,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FavouriteStatus.error,
          errorMessage: failure.message,
        );
      },
      (addedFavourite) {
        state = state.copyWith(
          status: FavouriteStatus.added,
          favourites: [...state.favourites, addedFavourite],
          currentFavourite: addedFavourite,
        );
      },
    );
  }

  // Get my favourites
  Future<void> getMyFavourites(String userId) async {
    state = state.copyWith(status: FavouriteStatus.loading);

    final result = await _getMyFavouritesUsecase(
      GetMyFavouritesParams(userId: userId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FavouriteStatus.error,
          errorMessage: failure.message,
        );
      },
      (favourites) {
        state = state.copyWith(
          status: FavouriteStatus.loaded,
          favourites: favourites,
        );
      },
    );
  }

  // Remove from favourites
  Future<void> removeFromFavourites(String favouriteId) async {
    state = state.copyWith(status: FavouriteStatus.removing);
    final params = RemoveFavouriteParams(favouriteId: favouriteId);
    final result = await _removeFromFavouritesUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FavouriteStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          final updatedFavourites = state.favourites
              .where((fav) => fav.favouriteId != favouriteId)
              .toList();

          state = state.copyWith(
            status: FavouriteStatus.removed,
            favourites: updatedFavourites,
            currentFavourite: null,
          );
        } else {
          state = state.copyWith(
            status: FavouriteStatus.error,
            errorMessage: "Failed to remove favourite",
          );
        }
      },
    );
  }

  // Reset state
  void resetState() {
    state = const FavouriteState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(status: FavouriteStatus.initial, errorMessage: null);
  }
}
