import 'package:flutter/material.dart';

class FavouritesErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final Color cardPurple;

  const FavouritesErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
    required this.cardPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'Failed to load favourites',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: cardPurple,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
