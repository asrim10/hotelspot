import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/features/auth/presentation/pages/login_page.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_history_page.dart';
import 'package:hotelspot/features/favourites/presentation/pages/favourite_page.dart';
import 'package:hotelspot/features/home/presentation/pages/home_page.dart';
import 'package:hotelspot/features/auth/presentation/pages/profile_page.dart';
import 'package:hotelspot/features/home/presentation/widgets/bottom_navigation_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class MainBottomScreen extends ConsumerStatefulWidget {
  const MainBottomScreen({super.key});

  @override
  ConsumerState<MainBottomScreen> createState() => _MainBottomScreenState();
}

class _MainBottomScreenState extends ConsumerState<MainBottomScreen> {
  int _currentIndex = 0;
  StreamSubscription<int>? _proximitySub;
  bool _dialogShowing = false;

  final List<Widget> _screens = [
    const HomePage(),
    const FavouritesPage(),
    const BookingHistoryPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProximitySensor();
    });
  }

  void _startProximitySensor() {
    try {
      _proximitySub = ProximitySensor.events.listen((int event) {
        final isCovered = event == 1;
        // Handle logout dialog on any tab
        if (isCovered && !_dialogShowing && mounted) {
          setState(() => _dialogShowing = true);
          _showLogoutDialog();
        }
      }, onError: (e) => debugPrint('Proximity error: $e'));
    } catch (e) {
      debugPrint('Proximity sensor not available: $e');
    }
  }

  @override
  void dispose() {
    _proximitySub?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2140),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _dialogShowing = false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _dialogShowing = false);
              await ref.read(tokenServiceProvider).removeToken();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    ).then((_) => setState(() => _dialogShowing = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
