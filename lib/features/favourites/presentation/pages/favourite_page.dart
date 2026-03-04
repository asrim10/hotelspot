import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/presentation/state/favourite_state.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_empty_state.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_error_state.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_hotel_card.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_stub_card.dart';
import 'package:hotelspot/features/hotel/presentation/pages/hotel_details_page.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';

class FavouritesPage extends ConsumerStatefulWidget {
  const FavouritesPage({super.key});

  @override
  ConsumerState<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends ConsumerState<FavouritesPage> {
  static const Color topLeft = Color(0xFF0A0E21);
  static const Color cardPurple = Color(0xFF0A0E21);
  static const Color priceBlue = Color(0xFF1E90FF);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId =
          ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
      ref.read(favouriteViewModelProvider.notifier).getMyFavourites(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final favourites = favouriteState.favourites;

    return Scaffold(
      backgroundColor: topLeft,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Favourites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${favourites.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: cardPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _buildBody(favouriteState, favourites),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    FavouriteState favouriteState,
    List<FavouriteEntity> favourites,
  ) {
    if (favouriteState.status == FavouriteStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (favouriteState.status == FavouriteStatus.error) {
      return FavouritesErrorState(
        errorMessage: favouriteState.errorMessage,
        cardPurple: cardPurple,
        onRetry: () {
          final userId =
              ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';
          ref.read(favouriteViewModelProvider.notifier).getMyFavourites(userId);
        },
      );
    }

    if (favourites.isEmpty) {
      return const FavouritesEmptyState();
    }

    final allHotels = ref.watch(hotelViewmodelProvider).hotels;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: GridView.builder(
        itemCount: favourites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, index) {
          final fav = favourites[index];
          final matchingHotels = allHotels
              .where((h) => h.hotelId == fav.hotelId)
              .toList();
          final hotel = matchingHotels.isNotEmpty ? matchingHotels.first : null;

          void handleRemove() {
            ref
                .read(favouriteViewModelProvider.notifier)
                .removeFromFavourites(fav.favouriteId ?? '');
          }

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailsPage(hotelId: fav.hotelId),
              ),
            ),
            child: hotel != null
                ? FavouriteHotelCard(
                    hotel: hotel,
                    favourite: fav,
                    priceBlue: priceBlue,
                    onRemove: handleRemove,
                  )
                : FavouriteStubCard(fav: fav, onRemove: handleRemove),
          );
        },
      ),
    );
  }
}
