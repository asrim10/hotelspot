import 'package:flutter/material.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_history_page.dart';
import 'package:hotelspot/features/favourites/presentation/pages/favourite_page.dart';
import 'package:hotelspot/features/home/presentation/pages/home_page.dart';
import 'package:hotelspot/features/auth/presentation/pages/profile_page.dart';
import 'package:hotelspot/features/home/presentation/widgets/bottom_navigation_widget.dart';

class MainBottomScreen extends StatefulWidget {
  const MainBottomScreen({super.key});

  @override
  State<MainBottomScreen> createState() => _MainBottomScreenState();
}

class _MainBottomScreenState extends State<MainBottomScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const FavouritesPage(),
    const BookingHistoryPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
