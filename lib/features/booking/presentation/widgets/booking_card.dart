import 'package:flutter/material.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_mini_date_col.dart';
import 'package:hotelspot/features/booking/presentation/widgets/review_button.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String? imageUrl;
  final String? hotelName;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.imageUrl,
    this.hotelName,
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

  bool get _canReview =>
      booking.status.toLowerCase() == 'confirmed' ||
      booking.status.toLowerCase() == 'checked_out';

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
                    Row(
                      children: [
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
                                hotelName ?? booking.fullName,
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
                    Row(
                      children: [
                        BookingMiniDateCol(
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
                        BookingMiniDateCol(
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

                    //  Rate Your Stay button
                    if (_canReview) ...[
                      const SizedBox(height: 14),
                      Divider(color: Colors.white.withOpacity(0.07), height: 1),
                      const SizedBox(height: 12),
                      ReviewButton(
                        hotelId: booking.hotelId,
                        hotelName: hotelName ?? booking.fullName,
                        imageUrl: imageUrl,
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
}
