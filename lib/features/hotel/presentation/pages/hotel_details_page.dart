import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HotelDetailsPage extends ConsumerStatefulWidget {
  final String hotelId;

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  // Mock data - replace with actual data from your provider
  final List<String> hotelImages = [
    'assets/images/hotel1.jpg',
    'assets/images/hotel2.jpg',
    'assets/images/hotel3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E21),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Carousel
                  PageView.builder(
                    itemCount: hotelImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        hotelImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.hotel,
                              size: 100,
                              color: Colors.white38,
                            ),
                          );
                        },
                      );
                    },
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
                  // Rating Badge
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
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '4.9(150+)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Image indicators
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
                            color: _currentImageIndex == index
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
          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Sarangkot Lodge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'NRs.20K',
                          style: TextStyle(
                            color: Colors.orange[400],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    const Text(
                      'The hotel offers comfortable accommodations and rooms are equipped with modern facilities',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'COST',
                            value: '20K NRs',
                            subtitle: 'NIGHT',
                            icon: Icons.attach_money,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'MAPS',
                            value: '300KM',
                            subtitle: 'AWAY',
                            icon: Icons.location_on,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'AVAILABLE',
                            value: '10',
                            subtitle: 'LEFT',
                            icon: Icons.hotel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Amenities Section
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildAmenityChip('WiFi', Icons.wifi),
                        _buildAmenityChip('Parking', Icons.local_parking),
                        _buildAmenityChip('Restaurant', Icons.restaurant),
                        _buildAmenityChip('Pool', Icons.pool),
                        _buildAmenityChip('Gym', Icons.fitness_center),
                        _buildAmenityChip('Spa', Icons.spa),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Location Section
                    const Text(
                      'Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.map, size: 60, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Handle booking
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.hotel, size: 20),
              SizedBox(width: 8),
              Text(
                'See all rooms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: Colors.orange[400], size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.orange[400]),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
