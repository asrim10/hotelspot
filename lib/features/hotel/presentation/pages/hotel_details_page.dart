import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelDetailsPage extends ConsumerStatefulWidget {
  final String hotelId;

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  String? _currentUserId;

  // Shake detection
  static const double _shakeThreshold = 15.0;
  static const int _shakeTimeoutMs = 1000; // cooldown between shakes
  double _lastX = 0, _lastY = 0, _lastZ = 0;
  int _lastShakeTime = 0;
  bool _shakeListenerActive = false;

  // Heart animation controller
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;
  bool _showHeartBurst = false;

  @override
  void initState() {
    super.initState();

    // Heart burst animation
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScaleAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.8), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.8, end: 0.0), weight: 60),
        ]).animate(
          CurvedAnimation(parent: _heartAnimController, curve: Curves.easeOut),
        );

    Future.microtask(() async {
      ref.read(hotelViewmodelProvider.notifier).getHotelById(widget.hotelId);
      // Load current user ID
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';
      // Check if already favourited
      final favState = ref.read(favouriteViewModelProvider);
      final alreadyFav = favState.favourites.any(
        (f) => f.hotelId == widget.hotelId,
      );
      if (mounted) setState(() => _isFavorite = alreadyFav);
    });

    _startShakeDetection();
  }

  void _startShakeDetection() {
    if (_shakeListenerActive) return;
    _shakeListenerActive = true;

    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;

      final double x = event.x;
      final double y = event.y;
      final double z = event.z;

      final double deltaX = (x - _lastX).abs();
      final double deltaY = (y - _lastY).abs();
      final double deltaZ = (z - _lastZ).abs();

      final double magnitude = sqrt(
        deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ,
      );

      _lastX = x;
      _lastY = y;
      _lastZ = z;

      final int now = DateTime.now().millisecondsSinceEpoch;

      if (magnitude > _shakeThreshold &&
          (now - _lastShakeTime) > _shakeTimeoutMs) {
        _lastShakeTime = now;
        _onShakeDetected();
      }
    });
  }

  void _onShakeDetected() {
    if (!_isFavorite) {
      _toggleFavourite();
    } else {
      // Already favourited — just show a reminder snackbar
      _showSnackBar(
        message: '❤️ Already in your favourites!',
        color: const Color(0xFF485D88),
      );
    }
  }

  Future<void> _toggleFavourite() async {
    final favNotifier = ref.read(favouriteViewModelProvider.notifier);

    if (_isFavorite) {
      // Remove
      final favState = ref.read(favouriteViewModelProvider);
      final fav = favState.favourites.firstWhere(
        (f) => f.hotelId == widget.hotelId,
        orElse: () => FavouriteEntity(
          userId: _currentUserId ?? '',
          hotelId: widget.hotelId,
        ),
      );
      if (fav.favouriteId != null) {
        await favNotifier.removeFromFavourites(fav.favouriteId!);
        setState(() => _isFavorite = false);
        _showSnackBar(
          message: '💔 Removed from favourites',
          color: Colors.grey[700]!,
        );
      }
    } else {
      // Add
      await favNotifier.addToFavourites(
        FavouriteEntity(userId: _currentUserId ?? '', hotelId: widget.hotelId),
      );
      setState(() => _isFavorite = true);
      _triggerHeartBurst();
      _showSnackBar(
        message: '❤️ Added to favourites! Shake to save next time!',
        color: const Color(0xFF6C5CC4),
      );
    }
  }

  void _triggerHeartBurst() {
    setState(() => _showHeartBurst = true);
    _heartAnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeartBurst = false);
    });
  }

  void _showSnackBar({required String message, required Color color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelState = ref.watch(hotelViewmodelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: hotelState.status == HotelStatus.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : hotelState.status == HotelStatus.error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    hotelState.errorMessage ?? 'Failed to load hotel',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(hotelViewmodelProvider.notifier)
                        .getHotelById(widget.hotelId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : hotelState.selectedHotel == null
          ? const Center(
              child: Text(
                'Hotel not found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Stack(
              children: [
                _buildHotelContent(hotelState),

                // Heart burst animation overlay
                if (_showHeartBurst)
                  Center(
                    child: ScaleTransition(
                      scale: _heartScaleAnim,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 120,
                      ),
                    ),
                  ),

                // BOOK NOW BUTTON
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E21).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final hotel = hotelState.selectedHotel;
                              if (hotel == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookingPage(hotel: hotel),
                                ),
                              );
                            },
                            child: const Text(
                              "Book Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHotelContent(HotelState hotelState) {
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
            // Shake hint tooltip
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
            // Favourite button
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(_isFavorite),
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                ),
              ),
              onPressed: _toggleFavourite,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                hotelImages.isNotEmpty
                    ? PageView.builder(
                        itemCount: hotelImages.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
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
                    child: Row(
                      children: const [
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
                        child: _buildInfoCard(
                          title: 'COST',
                          value: '${(hotel.price).toStringAsFixed(0)} NRs',
                          subtitle: 'NIGHT',
                          icon: Icons.attach_money,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          title: 'ADDRESS',
                          value: hotel.address,
                          subtitle: 'LOCATION',
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
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
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Replace the old Container with this:
                  hotel.coordinates != null
                      ? ClipRRect(
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
                                  flags:
                                      InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.asrim.hotelspot.hotelspot',
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
                        )
                      : Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 60,
                                  color: Colors.white38,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hotel.address,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ]),
        ),
      ],
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
