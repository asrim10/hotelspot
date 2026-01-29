import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hotelspot/features/hotel/presentation/pages/add_hotel_page.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  // Convert screen index to navigation bar index
  int _getNavBarIndex(int screenIndex) {
    // screens: [Home(0), Favorites(1), Map(2), Profile(3)]
    // navbar:  [Home(0), Fav(1), Add(2), Map(3), Profile(4)]
    return screenIndex >= 2 ? screenIndex + 1 : screenIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: _getNavBarIndex(widget.currentIndex),
      backgroundColor: Colors.transparent,
      color: Theme.of(context).primaryColor,
      buttonBackgroundColor: Theme.of(context).primaryColor,
      height: 56,
      items: const [
        Icon(Icons.home, size: 28, color: Colors.white),
        Icon(Icons.favorite, size: 28, color: Colors.white),
        Icon(Icons.add, size: 28, color: Colors.white),
        Icon(Icons.location_on, size: 28, color: Colors.white),
        Icon(Icons.person, size: 28, color: Colors.white),
      ],
      onTap: (navBarIndex) {
        if (navBarIndex == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHotelPage()),
          );
          return;
        }
        int screenIndex = navBarIndex > 2 ? navBarIndex - 1 : navBarIndex;
        widget.onTap(screenIndex);
      },
    );
  }
}
