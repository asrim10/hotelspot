import 'package:flutter/material.dart';

class BookingForm extends StatefulWidget {
  final Function(DateTime checkIn, DateTime checkOut) onBookingSelected;

  const BookingForm({super.key, required this.onBookingSelected});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  DateTime? checkInDate;
  DateTime? checkOutDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3C4DA6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Book Hotel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Check-in
          const Text(
            "Check in",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  checkInDate = picked;
                  if (checkOutDate != null &&
                      checkOutDate!.isBefore(checkInDate!)) {
                    checkOutDate = null;
                  }
                });
              }
            },
            child: Text(
              checkInDate == null
                  ? "Select Check-in Date"
                  : "${checkInDate!.day}-${checkInDate!.month}-${checkInDate!.year}",
            ),
          ),

          const SizedBox(height: 20),

          // Check-out
          const Text(
            "Check out",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (checkInDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please select check-in date first"),
                  ),
                );
                return;
              }

              final picked = await showDatePicker(
                context: context,
                initialDate: checkInDate!.add(const Duration(days: 1)),
                firstDate: checkInDate!.add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 366)),
              );
              if (picked != null) {
                setState(() {
                  checkOutDate = picked;
                  if (checkInDate != null && checkOutDate != null) {
                    widget.onBookingSelected(checkInDate!, checkOutDate!);
                  }
                });
              }
            },
            child: Text(
              checkOutDate == null
                  ? "Select Check-out Date"
                  : "${checkOutDate!.day}-${checkOutDate!.month}-${checkOutDate!.year}",
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
