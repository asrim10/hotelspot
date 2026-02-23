import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_history_detail_page.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
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

  /// Resolve hotel image URL from the hotels state using hotelId
  String? _resolveImageUrl(String hotelId) {
    try {
      final hotelState = ref.read(hotelViewmodelProvider);
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
      return _buildErrorState(state.errorMessage);
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
        if (filtered.isEmpty) return _buildEmptyState(tab);
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
        return _BookingCard(
          booking: booking,
          imageUrl: imageUrl,
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

  Widget _buildEmptyState(String tab) {
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

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                ref.read(bookingViewModelProvider.notifier).getMyBookings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String? imageUrl;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    this.imageUrl,
  });

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF00D084);
      case 'cancelled':
        return Colors.redAccent;
      case 'checked_in':
        return const Color(0xFF1E90FF);
      case 'checked_out':
        return Colors.white54;
      default:
        return const Color(0xFFFFB74D);
    }
  }

  String get _statusLabel {
    switch (booking.status.toLowerCase()) {
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      default:
        return booking.status[0].toUpperCase() + booking.status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2140),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              // Colored status strip at top
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel image/icon + name + status badge
                    Row(
                      children: [
                        // ── Hotel image thumbnail ──────────────────────────
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF1E90FF),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.hotel,
                                                color: Colors.white38,
                                                size: 26,
                                              ),
                                            ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.hotel,
                                    color: Colors.white38,
                                    size: 26,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${booking.bookingId?.substring(0, 8).toUpperCase() ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Divider(color: Colors.white.withOpacity(0.07), height: 1),
                    const SizedBox(height: 14),

                    // Dates + price
                    Row(
                      children: [
                        _MiniDateCol(
                          label: 'Check-in',
                          date: booking.checkInDate,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 20,
                            height: 1,
                            color: Colors.white24,
                          ),
                        ),
                        _MiniDateCol(
                          label: 'Check-out',
                          date: booking.checkOutDate,
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'NRs.${booking.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF1E90FF),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Payment info
                    if (booking.paymentStatus != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            booking.paymentStatus == 'paid'
                                ? Icons.check_circle_outline
                                : Icons.schedule_outlined,
                            size: 13,
                            color: booking.paymentStatus == 'paid'
                                ? const Color(0xFF00D084)
                                : const Color(0xFFFFB74D),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Payment: ${_cap(booking.paymentStatus!)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: booking.paymentStatus == 'paid'
                                  ? const Color(0xFF00D084)
                                  : const Color(0xFFFFB74D),
                            ),
                          ),
                          if (booking.paymentMethod != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '· ${_cap(booking.paymentMethod!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MiniDateCol extends StatelessWidget {
  final String label;
  final String date;

  const _MiniDateCol({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
