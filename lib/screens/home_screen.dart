import 'package:flutter/material.dart';
import 'package:hotelspot/widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen")),
      body: Text("Home Screen"),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
