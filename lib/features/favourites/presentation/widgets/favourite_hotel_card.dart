import 'package:flutter/material.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';

class FavouriteHotelCard extends StatelessWidget {
  final dynamic hotel;
  final FavouriteEntity favourite;
  final Color priceBlue;
  final VoidCallback onRemove;

  const FavouriteHotelCard({
    super.key,
    required this.hotel,
    required this.favourite,
    required this.priceBlue,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final imageUrl = hotel.imageUrl ?? '';
    final fullImageUrl = imageUrl.isNotEmpty ? '$baseUrl$imageUrl' : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                if (fullImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.network(
                      fullImageUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.hotel,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.hotel, size: 40, color: Colors.grey),
                    ),
                  ),

                // Price badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: priceBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NRs.${(hotel.price as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Remove favourite button
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              hotel.hotelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 13),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(fontSize: 11),
                ),
                const Spacer(),
                const Icon(Icons.location_on, size: 13, color: Colors.grey),
                Expanded(
                  child: Text(
                    hotel.city,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F4),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.bed_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'View details',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
