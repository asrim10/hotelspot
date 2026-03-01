import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_history_detail_page.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_card.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_empty_state.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_error_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';

class BookingHistoryPage extends ConsumerStatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  ConsumerState<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends ConsumerState<BookingHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Confirmed', 'Pending', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).getMyBookings();
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingEntity> _getUserBookings(
    List<BookingEntity> all,
    String? userId,
  ) {
    if (userId == null) return [];
    return all.where((b) => b.userId == userId).toList()..sort((a, b) {
      final aDate = a.createdAt ?? DateTime(0);
      final bDate = b.createdAt ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
  }

  List<BookingEntity> _filterByTab(List<BookingEntity> bookings, String tab) {
    if (tab == 'All') return bookings;
    return bookings
        .where((b) => b.status.toLowerCase() == tab.toLowerCase())
        .toList();
  }

  String? _resolveImageUrl(String hotelId) {
    try {
      final hotelState = ref.watch(hotelViewmodelProvider);
      final hotel = hotelState.hotels.firstWhere(
        (h) => h.hotelId == hotelId,
        orElse: () => throw Exception('not found'),
      );
      final rawPath = hotel.imageUrl ?? '';
      if (rawPath.isEmpty) return null;
      final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
      return '$baseUrl$rawPath';
    } catch (_) {
      return null;
    }
  }

  String? _resolveHotelName(String hotelId) {
    try {
      final hotelState = ref.watch(hotelViewmodelProvider);
      return hotelState.hotels
          .firstWhere((h) => h.hotelId == hotelId)
          .hotelName;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final currentUserId = ref
        .read(userSessionServiceProvider)
        .getCurrentUserId();
    final userBookings = _getUserBookings(bookingState.bookings, currentUserId);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF1E90FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF1E90FF),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _buildBody(bookingState, userBookings, currentUserId),
    );
  }

  Widget _buildBody(
    BookingState state,
    List<BookingEntity> userBookings,
    String? currentUserId,
  ) {
    if (state.status == BookingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
      );
    }

    if (state.status == BookingStatus.error) {
      return BookingErrorState(
        message: state.errorMessage,
        onRetry: () =>
            ref.read(bookingViewModelProvider.notifier).getMyBookings(),
      );
    }

    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view your bookings',
          style: TextStyle(color: Colors.white54, fontSize: 15),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        final filtered = _filterByTab(userBookings, tab);
        if (filtered.isEmpty) return BookingEmptyState(tab: tab);
        return _buildList(filtered);
      }).toList(),
    );
  }

  Widget _buildList(List<BookingEntity> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final imageUrl = _resolveImageUrl(booking.hotelId);
        final hotelName = _resolveHotelName(booking.hotelId);
        return BookingCard(
          booking: booking,
          imageUrl: imageUrl,
          hotelName: hotelName,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingHistoryDetailPage(
                booking: booking,
                imageUrl: imageUrl,
              ),
            ),
          ),
        );
      },
    );
  }
}
