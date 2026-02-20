import 'package:flutter/material.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/screens/main_bottom_screen.dart';

class BookingConfirmationPage extends StatelessWidget {
  final BookingEntity booking;

  const BookingConfirmationPage({Key? key, required this.booking})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D084).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF00D084),
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success Title
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Booking Details Text
              Text(
                'Your booking has been confirmed successfully.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Booking Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2140),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking ID
                    _buildInfoRow(
                      label: 'Booking ID',
                      value: booking.bookingId ?? 'N/A',
                    ),
                    const SizedBox(height: 16),

                    // Guest Name
                    _buildInfoRow(label: 'Guest Name', value: booking.fullName),
                    const SizedBox(height: 16),

                    // Email
                    _buildInfoRow(label: 'Email', value: booking.email),
                    const SizedBox(height: 16),

                    // Check In
                    _buildInfoRow(
                      label: 'Check In',
                      value: booking.checkInDate,
                    ),
                    const SizedBox(height: 16),

                    // Check Out
                    _buildInfoRow(
                      label: 'Check Out',
                      value: booking.checkOutDate,
                    ),
                    const SizedBox(height: 16),

                    // Total Amount
                    _buildInfoRow(
                      label: 'Total Amount',
                      value: 'NRs.${booking.totalPrice.toStringAsFixed(0)}',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainBottomScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C73D2), Color(0xFF845EC2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'CONTINUE SHOPPING',
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

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF1E90FF) : Colors.white,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
