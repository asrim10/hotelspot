import 'package:flutter/material.dart';
import 'package:hotelspot/features/auth/presentation/pages/login_screen.dart';

class OnBoarding3Screen extends StatelessWidget {
  const OnBoarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF183A63), Color(0xFF6B4BCF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            child: _buildImageContainer(
                              'assets/images/hotel1.jpeg',
                              size: 100,
                            ),
                          ),

                          Positioned(
                            left: 0,
                            child: _buildImageContainer(
                              'assets/images/hotel2.jpeg',
                              size: 100,
                            ),
                          ),

                          Positioned(
                            right: 0,
                            child: _buildImageContainer(
                              'assets/images/hotel3.jpeg',
                              size: 100,
                            ),
                          ),

                          Positioned(
                            child: _buildImageContainer(
                              'assets/images/hotel4.jpeg',
                              size: 120,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 20,
                            child: _buildImageContainer(
                              'assets/images/hotel5.jpeg',
                              size: 100,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 20,
                            child: _buildImageContainer(
                              'assets/images/hotel6.jpeg',
                              size: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  const Text(
                    "Discover Your Perfect Stay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'With HotelSpot',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Find and book the best hotels effortlessly—affordable, comfortable, and perfectly matched to your needs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Let's Go",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imagePath, {required double size}) {
    return Transform.rotate(
      angle: 0.3, // diamond effect
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[400],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
