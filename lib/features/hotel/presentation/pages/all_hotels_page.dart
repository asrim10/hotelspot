import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/pages/hotel_details_page.dart';
import 'package:hotelspot/features/hotel/presentation/widgets/hotel_card.dart';

class AllHotelsPage extends ConsumerStatefulWidget {
  const AllHotelsPage({super.key});

  @override
  ConsumerState<AllHotelsPage> createState() => _AllHotelsPageState();
}

class _AllHotelsPageState extends ConsumerState<AllHotelsPage> {
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color accentPurple = Color(0xFF6C5CC4);
  static const Color priceBlue = Color(0xFF1E90FF);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotelState = ref.watch(hotelViewmodelProvider);
    final hotels = hotelState.hotels;

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          'All Hotels',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Show loading, error, or hotels
                if (hotelState.status == HotelStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: accentPurple),
                    ),
                  )
                else if (hotelState.status == HotelStatus.error)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        hotelState.errorMessage ?? 'Failed to load hotels',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else if (hotels.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No hotels available',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  // Display all hotels in list format
                  Column(
                    children: List.generate(hotels.length, (index) {
                      final hotel = hotels[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            if (hotel.hotelId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HotelDetailsPage(hotelId: hotel.hotelId!),
                                ),
                              );
                            }
                          },
                          child: HotelCard(
                            hotel: hotel,
                            cardDark: cardDark,
                            accentPurple: accentPurple,
                            priceBlue: priceBlue,
                            onTap: () {
                              if (hotel.hotelId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HotelDetailsPage(
                                      hotelId: hotel.hotelId!,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
