import 'package:flutter/material.dart';
import 'package:hotelspot/features/auth/presentation/pages/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnBoardingPageData> _pages = [
    OnBoardingPageData(
      title: "Let's Find Your Sweet",
      subtitle: '& Dream Place',
      description:
          'Get the opportunity to stay that you dream of at an affordable price',
      buttonText: 'Next',
    ),
    OnBoardingPageData(
      title: "Best Deals and offers",
      subtitle:
          'Find the best deals and offers for your stay at affordable prices',
      description:
          'Discover exclusive discounts and special offers on hotels worldwide. Book now and save big on your next adventure!',
      buttonText: 'Next',
    ),
    OnBoardingPageData(
      title: "Discover Your Perfect Stay",
      subtitle: 'With HotelSpot',
      description:
          'Find and book the best hotels effortlessly—affordable, comfortable, and perfectly matched to your needs.',
      buttonText: "Let's Go",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - navigate to login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

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
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              // Dots indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnBoardingPageData pageData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Image Stack
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

          // Title
          Text(
            pageData.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (pageData.subtitle.isNotEmpty) ...[
            Text(
              pageData.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Description
          Text(
            pageData.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 48),

          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _onNextPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                pageData.buttonText,
                style: const TextStyle(
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

class OnBoardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;

  OnBoardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
  });
}
