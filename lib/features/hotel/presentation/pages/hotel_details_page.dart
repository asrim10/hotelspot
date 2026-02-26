import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/widgets/hotel_details_content.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_page.dart';
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

  static const double _shakeThreshold = 15.0;
  static const int _shakeTimeoutMs = 1000;
  double _lastX = 0, _lastY = 0, _lastZ = 0;
  int _lastShakeTime = 0;
  bool _shakeListenerActive = false;

  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;
  bool _showHeartBurst = false;

  @override
  void initState() {
    super.initState();

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
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';
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
      _showSnackBar(
        message: '❤️ Already in your favourites!',
        color: const Color(0xFF485D88),
      );
    }
  }

  Future<void> _toggleFavourite() async {
    final favNotifier = ref.read(favouriteViewModelProvider.notifier);

    if (_isFavorite) {
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
                HotelDetailsContent(
                  hotelState: hotelState,
                  isFavorite: _isFavorite,
                  currentImageIndex: _currentImageIndex,
                  onImagePageChanged: (index) =>
                      setState(() => _currentImageIndex = index),
                  onToggleFavourite: _toggleFavourite,
                ),

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

                // Book Now button
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
}
