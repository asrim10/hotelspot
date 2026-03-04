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
  int _rebuildKey = 0;

  int _getNavBarIndex(int screenIndex) {
    return screenIndex >= 2 ? screenIndex + 1 : screenIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      key: ValueKey(_rebuildKey),
      index: _getNavBarIndex(widget.currentIndex),
      backgroundColor: Colors.transparent,
      color: Theme.of(context).primaryColor,
      buttonBackgroundColor: Theme.of(context).primaryColor,
      height: 56,
      items: const [
        Icon(Icons.home, size: 28, color: Colors.white),
        Icon(Icons.favorite, size: 28, color: Colors.white),
        Icon(Icons.add, size: 28, color: Colors.white),
        Icon(Icons.history, size: 28, color: Colors.white),
        Icon(Icons.person, size: 28, color: Colors.white),
      ],
      onTap: (navBarIndex) {
        if (navBarIndex == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHotelPage()),
          ).then((_) {
            widget.onTap(0);
            setState(() => _rebuildKey++);
          });
          return;
        }
        int screenIndex = navBarIndex > 2 ? navBarIndex - 1 : navBarIndex;
        widget.onTap(screenIndex);
      },
    );
  }
}
