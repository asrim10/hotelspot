import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_app_color.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_banner.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_filter_sheet.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_search_bar.dart';
import 'package:hotelspot/features/home/presentation/widgets/hotel_grid.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/pages/all_hotels_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomePage> {
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FilterOptions _filterOptions = const FilterOptions();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
      ref.read(favouriteViewModelProvider.notifier).getMyFavourites('me');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      if (mounted) setState(() => _currentUserId = userId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterHotels(List<dynamic> hotels) {
    return hotels.where((hotel) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (hotel.hotelName as String).toLowerCase();
        final city = (hotel.city as String).toLowerCase();
        if (!name.contains(query) && !city.contains(query)) return false;
      }

      // Price filter
      final price = hotel.price as double;
      if (_filterOptions.minPrice != null && price < _filterOptions.minPrice!) {
        return false;
      }
      if (_filterOptions.maxPrice != null && price > _filterOptions.maxPrice!) {
        return false;
      }

      // Rating filter
      final rating = (hotel.rating as num).toDouble();
      if (_filterOptions.minRating != null &&
          rating < _filterOptions.minRating!) {
        return false;
      }

      // City filter
      if (_filterOptions.city != null &&
          (hotel.city as String).toLowerCase() !=
              _filterOptions.city!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openFilterSheet(List<dynamic> allHotels) {
    final cities = allHotels.map((h) => h.city as String).toSet().toList()
      ..sort();

    HomeFilterSheet.show(
      context: context,
      current: _filterOptions,
      availableCities: cities,
      onApply: (options) => setState(() => _filterOptions = options),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotelState = ref.watch(hotelViewmodelProvider);
    final hotels = hotelState.hotels;
    final filteredHotels = _filterHotels(hotels);
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final favouriteHotelIds = favouriteState.favourites
        .map((f) => f.hotelId)
        .toSet();
    final isFiltering = _searchQuery.isNotEmpty || _filterOptions.isActive;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF0A0E21)),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSearchBar(
                      controller: _searchController,
                      searchQuery: _searchQuery,
                      filterActive: _filterOptions.isActive,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value.trim()),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      onFilter: () => _openFilterSheet(hotels),
                    ),
                    if (!isFiltering) ...[
                      const SizedBox(height: 12),
                      const HomeBanner(),
                    ],
                  ],
                ),
              ),

              // Main card
              Container(
                transform: Matrix4.translationValues(0, -26, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFiltering ? 'Results' : 'Top Hotels',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isFiltering
                                    ? '${filteredHotels.length} hotel${filteredHotels.length == 1 ? '' : 's'} found'
                                    : 'Best picks for your stay',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (!isFiltering)
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllHotelsPage(),
                                ),
                              ),
                              child: const Text(
                                'See all',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            // Clear filters button
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filterOptions = const FilterOptions();
                                });
                              },
                              child: const Text(
                                'Clear all',
                                style: TextStyle(
                                  color: Color(0xFF1E90FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // States
                      if (hotelState.status == HotelStatus.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (hotelState.status == HotelStatus.error)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              hotelState.errorMessage ??
                                  'Failed to load hotels',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      else if (filteredHotels.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  color: Colors.white38,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isFiltering
                                      ? 'No hotels match your filters'
                                      : 'No hotels available',
                                  style: const TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        HotelGrid(
                          hotels: filteredHotels,
                          favouriteHotelIds: favouriteHotelIds,
                          currentUserId: _currentUserId,
                        ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
