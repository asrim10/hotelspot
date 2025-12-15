import 'package:flutter/material.dart';
import 'package:hotelspot/widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top gradient/header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2F4876), Color(0xFF6C5CC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Hotel\'s...'.toUpperCase(),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Promo card
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: NetworkImage('https://picsum.photos/seed/promo/800/400'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.35), Colors.black26],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Book best hotel with us!',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Book Now'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Body area
              Container(
                width: double.infinity,
                transform: Matrix4.translationValues(0, -24, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(onPressed: () {}, child: const Text('See more')),
                      ],
                    ),

                    // Categories list
                    SizedBox(
                      height: 92,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryCard(Icons.hotel, 'HOTEL'),
                          _buildCategoryCard(Icons.villa, 'VILLA'),
                          _buildCategoryCard(Icons.beach_access, 'RESORT'),
                          _buildCategoryCard(Icons.apartment, 'APARTMENT'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Grid of hotels
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.72,
                      children: List.generate(6, (index) => _buildHotelCard(context, index)),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    return Container(
      width: 84,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
            ),
            child: Icon(icon, color: const Color(0xFF2F4876)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, int index) {
    final img = 'https://picsum.photos/seed/h$index/400/300';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image + badges
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Image.network(img, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(Icons.favorite_border, color: Colors.white),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
                    child: const Text('NRs.20K', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sarangkot Lodge', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      const Text('4.9(150+)', style: TextStyle(fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Pokhara', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

