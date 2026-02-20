import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_details_page.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

class BookingPage extends ConsumerStatefulWidget {
  final HotelEntity hotel;

  const BookingPage({super.key, required this.hotel});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage>
    with SingleTickerProviderStateMixin {
  DateTime? selectedCheckInDate;
  DateTime? selectedCheckOutDate;

  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  int get totalNights {
    if (selectedCheckInDate != null && selectedCheckOutDate != null) {
      return selectedCheckOutDate!.difference(selectedCheckInDate!).inDays;
    }
    return 0;
  }

  double get totalPrice => totalNights * widget.hotel.price;

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedCheckInDate = picked;
        checkInController.text = _formatDate(picked);
        selectedCheckOutDate = null;
        checkOutController.clear();
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (selectedCheckInDate == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedCheckInDate!.add(const Duration(days: 1)),
      firstDate: selectedCheckInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedCheckOutDate = picked;
        checkOutController.text = _formatDate(picked);
      });
    }
  }

  @override
  void dispose() {
    checkInController.dispose();
    checkOutController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    final imageUrl = (widget.hotel.imageUrl ?? '').isNotEmpty
        ? '$baseUrl${widget.hotel.imageUrl}'
        : null;

    final isValid = selectedCheckInDate != null && selectedCheckOutDate != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HOTEL IMAGE HEADER
                  Stack(
                    children: [
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey[800]),
                      ),
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // HOTEL INFO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hotel.hotelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.hotel.rating.toString(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "NRs. ${widget.hotel.price.toStringAsFixed(0)} / night",
                          style: const TextStyle(
                            color: Color(0xFF1E90FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  //DATE FIELDS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildDateField(
                          "Check-in",
                          checkInController,
                          _selectCheckInDate,
                        ),
                        const SizedBox(height: 20),
                        _buildDateField(
                          "Check-out",
                          checkOutController,
                          _selectCheckOutDate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOOKING SUMMARY
                  if (totalNights > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2140),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _summaryRow("Nights", "$totalNights"),
                            const SizedBox(height: 10),
                            _summaryRow(
                              "Total Price",
                              "NRs. ${totalPrice.toStringAsFixed(0)}",
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      //PREMIUM CONTINUE BUTTON
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF0A0E21),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isValid
                  ? [const Color(0xFF00C9FF), const Color(0xFF92FE9D)]
                  : [Colors.grey, Colors.grey],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: isValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsPage(
                            hotel: widget.hotel,
                            checkInDate: selectedCheckInDate!,
                            checkOutDate: selectedCheckOutDate!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Center(
                child: Text(
                  "CONTINUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Select date",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
