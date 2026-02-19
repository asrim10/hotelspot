import 'package:flutter/material.dart';

class HotelHeader extends StatelessWidget {
  final String? imageUrl;

  const HotelHeader({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Hotel Image
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[800]),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.hotel,
                            color: Colors.white38,
                            size: 80,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.hotel, color: Colors.white38, size: 80),
                    ),
            ),

            // Dark overlay
            Container(
              height: 230,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 14,
              left: 14,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              top: 14,
              right: 14,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ),

            // Header Text
            const Positioned(
              bottom: 20,
              left: 18,
              right: 18,
              child: Text(
                "Choose best hotels\naround the world!!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),

            // Favorite icon
            Positioned(
              top: 100,
              right: 18,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
