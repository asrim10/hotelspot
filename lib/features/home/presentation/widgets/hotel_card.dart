import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/home/presentation/widgets/favourite_button.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_app_color.dart';

class HotelCard extends ConsumerWidget {
  final dynamic hotel;
  final Set<String> favouriteHotelIds;
  final String? currentUserId;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.favouriteHotelIds,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final imageUrl = hotel.imageUrl ?? '';
    final fullImageUrl = imageUrl.isNotEmpty ? '$baseUrl$imageUrl' : '';
    final isFavourited =
        hotel.hotelId != null && favouriteHotelIds.contains(hotel.hotelId);

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                if (fullImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      fullImageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.hotel,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.hotel, size: 50, color: Colors.grey),
                    ),
                  ),

                // Favourite button
                Positioned(
                  top: 8,
                  left: 8,
                  child: FavouriteButton(
                    isFavourited: isFavourited,
                    onTap: () async {
                      if (hotel.hotelId == null) return;
                      final favNotifier = ref.read(
                        favouriteViewModelProvider.notifier,
                      );

                      if (isFavourited) {
                        final favState = ref.read(favouriteViewModelProvider);
                        final fav = favState.favourites.firstWhere(
                          (f) => f.hotelId == hotel.hotelId,
                          orElse: () => FavouriteEntity(
                            userId: currentUserId ?? '',
                            hotelId: hotel.hotelId!,
                          ),
                        );
                        if (fav.favouriteId != null) {
                          await favNotifier.removeFromFavourites(
                            fav.favouriteId!,
                          );
                        }
                      } else {
                        await favNotifier.addToFavourites(
                          FavouriteEntity(
                            userId: currentUserId ?? '',
                            hotelId: hotel.hotelId!,
                          ),
                        );
                      }
                    },
                  ),
                ),

                // Price badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: HomeAppColors.priceBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NRs.${(hotel.price as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hotel name
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(
              hotel.hotelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Rating & city
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hotel.city,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom bar
          Container(
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F4),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  'NRs.${(hotel.price as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
