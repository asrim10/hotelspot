import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';

enum FavouriteStatus {
  initial,
  loading,
  loaded,
  adding,
  added,
  removing,
  removed,
  error,
}

class FavouriteState extends Equatable {
  final FavouriteStatus status;
  final List<FavouriteEntity> favourites;
  final FavouriteEntity? currentFavourite;
  final String? errorMessage;

  const FavouriteState({
    this.status = FavouriteStatus.initial,
    this.favourites = const [],
    this.currentFavourite,
    this.errorMessage,
  });

  FavouriteState copyWith({
    FavouriteStatus? status,
    List<FavouriteEntity>? favourites,
    FavouriteEntity? currentFavourite,
    String? errorMessage,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      favourites: favourites ?? this.favourites,
      currentFavourite: currentFavourite ?? this.currentFavourite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    favourites,
    currentFavourite,
    errorMessage,
  ];
}
