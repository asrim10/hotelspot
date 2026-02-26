import 'package:flutter/material.dart';

class BookingEmptyState extends StatelessWidget {
  final String tab;

  const BookingEmptyState({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2140),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.hotel, color: Colors.white38, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            tab == 'All'
                ? 'No bookings yet'
                : 'No ${tab.toLowerCase()} bookings',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tab == 'All'
                ? 'Your reservations will appear here'
                : 'You have no ${tab.toLowerCase()} reservations',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
