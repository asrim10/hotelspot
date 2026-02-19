import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/pages/hotel_details_page.dart';

class AllHotelsPage extends ConsumerStatefulWidget {
  const AllHotelsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AllHotelsPage> createState() => _AllHotelsPageState();
}

class _AllHotelsPageState extends ConsumerState<AllHotelsPage> {
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color accentPurple = Color(0xFF6C5CC4);
  static const Color priceBlue = Color(0xFF1E90FF);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotelState = ref.watch(hotelViewmodelProvider);
    final hotels = hotelState.hotels;

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          'All Hotels',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Show loading, error, or hotels
                if (hotelState.status == HotelStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: accentPurple),
                    ),
                  )
                else if (hotelState.status == HotelStatus.error)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        hotelState.errorMessage ?? 'Failed to load hotels',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else if (hotels.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No hotels available',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  // Display all hotels in list format
                  Column(
                    children: List.generate(hotels.length, (index) {
                      final hotel = hotels[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            if (hotel.hotelId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HotelDetailsPage(hotelId: hotel.hotelId!),
                                ),
                              );
                            }
                          },
                          child: _hotelCard(hotel),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hotelCard(dynamic hotel) {
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final fullImageUrl = (hotel.imageUrl ?? '').isNotEmpty
        ? '$baseUrl${hotel.imageUrl}'
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Rating and Favorite
            Stack(
              children: [
                // Image
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: fullImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            fullImageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.hotel,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: accentPurple,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.hotel,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),

                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.rating.toStringAsFixed(1)}(150+)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite Heart
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Dots Indicator
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == 0 ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Hotel Info Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.hotelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NRs.${hotel.price.toStringAsFixed(0)}k',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    hotel.description ?? 'Premium hotel with modern amenities',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // See All Rooms Button
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priceBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: priceBlue.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: priceBlue, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Details',
                            style: TextStyle(
                              color: priceBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Info Row (Cost, Maps, Available)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        // Cost
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'COST',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NRs.${(hotel.price * 1000).toStringAsFixed(0)}/night',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        // Maps
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white54,
                                size: 14,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${hotel.city}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        // Available
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'AVAILABLE',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${hotel.availableRooms} LEFT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
