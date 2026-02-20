import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

class BookingDetailsPage extends ConsumerStatefulWidget {
  final HotelEntity hotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const BookingDetailsPage({
    Key? key,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  ConsumerState<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends ConsumerState<BookingDetailsPage> {
  Future<void> _submitBooking() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();
    final fullName = userSessionService.getCurrentUserFullName();
    final email = userSessionService.getCurrentUserEmail();

    if (userId == null || fullName == null || email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User session not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Create booking entity
    final booking = BookingEntity(
      userId: userId,
      hotelId: widget.hotel.hotelId ?? '',
      fullName: fullName,
      email: email,
      checkInDate: widget.checkInDate.toIso8601String().split('T')[0],
      checkOutDate: widget.checkOutDate.toIso8601String().split('T')[0],
      totalPrice:
          widget.hotel.price *
          widget.checkOutDate.difference(widget.checkInDate).inDays,
      status: 'pending',
      paymentMethod: 'card',
      paymentStatus: 'pending',
    );

    // Call booking view model to create booking
    await ref.read(bookingViewModelProvider.notifier).createBooking(booking);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to booking state changes
    ref.listen<BookingState>(bookingViewModelProvider, (previous, next) {
      if (next.status == BookingStatus.created) {
        // Navigate to confirmation page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                BookingConfirmationPage(booking: next.currentBooking!),
          ),
        );
      } else if (next.status == BookingStatus.error &&
          previous?.status != BookingStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Booking failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final imageUrl = (widget.hotel.imageUrl ?? '').isNotEmpty
        ? '$baseUrl${widget.hotel.imageUrl}'
        : null;

    final days = widget.checkOutDate.difference(widget.checkInDate).inDays;
    final totalAmount = widget.hotel.price * days;

    // Watch booking state to show loading indicator
    final bookingState = ref.watch(bookingViewModelProvider);
    final isProcessing = bookingState.status == BookingStatus.creating;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Booking Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Hotel Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2140),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Hotel Image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.hotel,
                                        color: Colors.white38,
                                        size: 40,
                                      ),
                                    ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.hotel,
                                color: Colors.white38,
                                size: 40,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Hotel Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hotel.hotelName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white54,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.hotel.city}, ${widget.hotel.country}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NRs.${widget.hotel.price.toStringAsFixed(0)}/Day',
                            style: const TextStyle(
                              color: Color(0xFF1E90FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Booking Details
              const Text(
                'Booking Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Check In
              _buildDetailRow(
                label: 'Check In',
                value: _formatDate(widget.checkInDate),
              ),
              const SizedBox(height: 16),

              // Check Out
              _buildDetailRow(
                label: 'Check Out',
                value: _formatDate(widget.checkOutDate),
              ),
              const SizedBox(height: 16),

              // Number of Days
              _buildDetailRow(label: 'Number of Days', value: '$days Days'),

              const SizedBox(height: 32),

              // Price Breakdown
              const Text(
                'Price Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              _buildPriceRow(
                label: 'Amount',
                value: 'NRs.${(widget.hotel.price * days).toStringAsFixed(0)}',
              ),

              const SizedBox(height: 20),

              // Total
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E90FF).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF1E90FF).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NRs.${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF1E90FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Pay Now Button
              GestureDetector(
                onTap: isProcessing ? null : _submitBooking,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: isProcessing
                          ? [Colors.grey[700]!, Colors.grey[600]!]
                          : [const Color(0xFF2C73D2), const Color(0xFF845EC2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'PAY NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D084),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
