import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/widgets/hotel_amenity_chip.dart';
import 'package:hotelspot/features/hotel/presentation/widgets/hotel_info_card.dart';
import 'package:latlong2/latlong.dart';

class HotelDetailsContent extends StatelessWidget {
  final HotelState hotelState;
  final bool isFavorite;
  final int currentImageIndex;
  final ValueChanged<int> onImagePageChanged;
  final VoidCallback onToggleFavourite;

  const HotelDetailsContent({
    super.key,
    required this.hotelState,
    required this.isFavorite,
    required this.currentImageIndex,
    required this.onImagePageChanged,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final hotel = hotelState.selectedHotel!;
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final String? fullImageUrl = (hotel.imageUrl ?? '').isNotEmpty
        ? '$baseUrl${hotel.imageUrl}'
        : null;
    final List<String> hotelImages = fullImageUrl != null ? [fullImageUrl] : [];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: const Color(0xFF0A0E21),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Shake to favourite!',
                child: Icon(
                  Icons.vibration,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
              ),
            ),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
              ),
              onPressed: onToggleFavourite,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                hotelImages.isNotEmpty
                    ? PageView.builder(
                        itemCount: hotelImages.length,
                        onPageChanged: onImagePageChanged,
                        itemBuilder: (context, index) {
                          return Image.network(
                            hotelImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.hotel,
                                    size: 100,
                                    color: Colors.white38,
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.hotel,
                          size: 100,
                          color: Colors.white38,
                        ),
                      ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A0E21).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 120,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Shake hint badge
                Positioned(
                  top: 120,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.vibration, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Shake to ❤️',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                // Image indicators
                if (hotelImages.length > 1)
                  Positioned(
                    bottom: 180,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        hotelImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.hotelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'NRs.${hotel.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.orange[400],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.city}, ${hotel.country}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hotel.description ??
                        'The hotel offers comfortable accommodations and rooms are equipped with modern facilities',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: HotelInfoCard(
                          title: 'COST',
                          value: 'Nrs.${hotel.price.toStringAsFixed(0)}',
                          subtitle: 'NIGHT',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HotelInfoCard(
                          title: 'ADDRESS',
                          value: hotel.address,
                          subtitle: 'LOCATION',
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HotelInfoCard(
                          title: 'AVAILABLE',
                          value: '${hotel.availableRooms}',
                          subtitle: 'LEFT',
                          icon: Icons.hotel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      HotelAmenityChip(label: 'WiFi', icon: Icons.wifi),
                      HotelAmenityChip(
                        label: 'Parking',
                        icon: Icons.local_parking,
                      ),
                      HotelAmenityChip(
                        label: 'Restaurant',
                        icon: Icons.restaurant,
                      ),
                      HotelAmenityChip(label: 'Pool', icon: Icons.pool),
                      HotelAmenityChip(
                        label: 'Gym',
                        icon: Icons.fitness_center,
                      ),
                      HotelAmenityChip(label: 'Spa', icon: Icons.spa),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMap(hotel),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildMap(HotelEntity hotel) {
    if (hotel.coordinates != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                hotel.coordinates!['lat']!,
                hotel.coordinates!['lng']!,
              ),
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.asrim.hotelspot.hotelspot',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      hotel.coordinates!['lat']!,
                      hotel.coordinates!['lng']!,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 60, color: Colors.white38),
            const SizedBox(height: 8),
            Text(
              hotel.address,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
