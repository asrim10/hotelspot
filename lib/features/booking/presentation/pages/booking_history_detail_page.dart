import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';

class BookingHistoryDetailPage extends ConsumerWidget {
  final BookingEntity booking;
  final String? imageUrl;

  const BookingHistoryDetailPage({
    super.key,
    required this.booking,
    this.imageUrl,
  });

  //  Status helpers

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
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

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  // ── Cancel dialog ────────────────────────────────────────────────────────

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    await ref
        .read(bookingViewModelProvider.notifier)
        .cancelBooking(booking.bookingId!, '');
    if (context.mounted) Navigator.pop(context);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int get _nights {
    try {
      final p1 = booking.checkInDate.split('-');
      final p2 = booking.checkOutDate.split('-');
      if (p1.length == 3 && p2.length == 3) {
        final ci = DateTime(
          int.parse(p1[0]),
          int.parse(p1[1]),
          int.parse(p1[2]),
        );
        final co = DateTime(
          int.parse(p2[0]),
          int.parse(p2[1]),
          int.parse(p2[2]),
        );
        return co.difference(ci).inDays;
      }
    } catch (_) {}
    return 0;
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fmtDateTime(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final isLoading =
        bookingState.status == BookingStatus.cancelling ||
        bookingState.status == BookingStatus.updating;

    final sc = _statusColor(booking.status);
    final nights = _nights;
    final canCancel = ![
      'cancelled',
      'checked_out',
    ].contains(booking.status.toLowerCase());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (booking.bookingId != null)
            IconButton(
              icon: const Icon(
                Icons.copy_outlined,
                color: Colors.white54,
                size: 20,
              ),
              tooltip: 'Copy Booking ID',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: booking.bookingId!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking ID copied!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF1A2140),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stay summary card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2140),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  // Hotel image banner OR plain coloured strip
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 160,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 160,
                              color: const Color(0xFF0F1829),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1E90FF),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 160,
                                color: const Color(0xFF0F1829),
                                child: const Center(
                                  child: Icon(
                                    Icons.hotel,
                                    color: Colors.white24,
                                    size: 48,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: sc,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                  // Thin status strip always visible beneath image
                  if (imageUrl != null) Container(height: 4, color: sc),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: sc.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sc.withOpacity(0.4)),
                          ),
                          child: Text(
                            _statusLabel(booking.status),
                            style: TextStyle(
                              color: sc,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Check-in / Check-out
                        Row(
                          children: [
                            _DateBlock(
                              label: 'Check-in',
                              date: booking.checkInDate,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '$nights night${nights != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF1E90FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: i > 0 ? 2 : 0,
                                          ),
                                          height: 1,
                                          color: Colors.white.withOpacity(0.15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _DateBlock(
                              label: 'Check-out',
                              date: booking.checkOutDate,
                              alignRight: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Divider(
                          color: Colors.white.withOpacity(0.07),
                          height: 1,
                        ),
                        const SizedBox(height: 16),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'NRs.${booking.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF1E90FF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Guest information ──────────────────────────────────────────
            _SectionTitle(title: 'Guest Information'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'Full Name', value: booking.fullName),
                _InfoRow(label: 'Email', value: booking.email),
              ],
            ),

            const SizedBox(height: 24),

            // ── Payment details ────────────────────────────────────────────
            _SectionTitle(title: 'Payment Details'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Amount',
                  value: 'NRs.${booking.totalPrice.toStringAsFixed(0)}',
                  valueColor: const Color(0xFF1E90FF),
                ),
                if (booking.paymentMethod != null)
                  _InfoRow(
                    label: 'Method',
                    value: _cap(booking.paymentMethod!),
                  ),
                if (booking.paymentStatus != null)
                  _InfoRow(
                    label: 'Status',
                    value: _cap(booking.paymentStatus!),
                    valueColor: booking.paymentStatus == 'paid'
                        ? const Color(0xFF00D084)
                        : const Color(0xFFFFB74D),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Booking info ───────────────────────────────────────────────
            _SectionTitle(title: 'Booking Info'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Booking ID',
                  value: booking.bookingId ?? 'N/A',
                  monospace: true,
                ),
                _InfoRow(
                  label: 'Hotel ID',
                  value: booking.hotelId,
                  monospace: true,
                ),
                if (booking.createdAt != null)
                  _InfoRow(
                    label: 'Booked On',
                    value: _fmtDateTime(booking.createdAt!),
                  ),
                if (booking.updatedAt != null)
                  _InfoRow(
                    label: 'Updated',
                    value: _fmtDateTime(booking.updatedAt!),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Cancel button ──────────────────────────────────────────────
            if (canCancel)
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E90FF),
                      ),
                    )
                  : GestureDetector(
                      onTap: booking.bookingId != null
                          ? () => _cancelBooking(context, ref)
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.6),
                          ),
                          color: Colors.redAccent.withOpacity(0.08),
                        ),
                        child: const Center(
                          child: Text(
                            'CANCEL BOOKING',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _DateBlock extends StatelessWidget {
  final String label;
  final String date;
  final bool alignRight;

  const _DateBlock({
    required this.label,
    required this.date,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.06),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool monospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
