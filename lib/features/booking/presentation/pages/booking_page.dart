import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_form.dart';
import 'package:hotelspot/features/booking/presentation/widgets/header.dart';
import 'package:hotelspot/features/booking/presentation/widgets/hotel_info.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

class BookingPage extends ConsumerStatefulWidget {
  final HotelEntity hotel;

  const BookingPage({super.key, required this.hotel});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  int selectedCheckInIndex = 0;
  int selectedCheckOutIndex = 0;

  late List<DateTime> checkInDates;
  late List<DateTime> checkOutDates;

  @override
  void initState() {
    super.initState();

    // Generate dates
    checkInDates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    checkOutDates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index + 1)),
    );
  }

  String formatDay(DateTime date) {
    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];
  }

  String formatMonth(DateTime date) {
    return [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ][date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);

    // Fix image url
    final baseUrl = ApiEndpoints.baseUrl.replaceAll("/api/v1", "");
    final imageUrl = (widget.hotel.imageUrl ?? "").isNotEmpty
        ? "$baseUrl${widget.hotel.imageUrl}"
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HotelHeader(imageUrl: imageUrl),
                    const SizedBox(height: 10),
                    HotelInfo(
                      hotelName: widget.hotel.hotelName,
                      city: widget.hotel.city,
                      country: widget.hotel.country,
                      price: widget.hotel.price,
                    ),
                    const SizedBox(height: 18),
                    BookingForm(
                      onBookingSelected: (checkIn, checkOut) {
                        // You can now use these dates to create a booking
                        print("Selected: $checkIn to $checkOut");
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.only(bottom: 18, left: 20, right: 20),
              child: GestureDetector(
                onTap: bookingState.status == BookingStatus.creating
                    ? null
                    : () async {
                        final checkIn = checkInDates[selectedCheckInIndex];
                        final checkOut = checkOutDates[selectedCheckOutIndex];

                        if (checkOut.isBefore(checkIn)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Check-out date must be after check-in date",
                              ),
                            ),
                          );
                          return;
                        }

                        final days = checkOut.difference(checkIn).inDays;
                        final totalPrice = widget.hotel.price * days;

                        final booking = BookingEntity(
                          bookingId: "",
                          userId: "",
                          hotelId: widget.hotel.hotelId!,
                          fullName: "Guest User",
                          email: "guest@gmail.com",
                          checkInDate: checkIn.toIso8601String().split('T')[0],
                          checkOutDate: checkOut.toIso8601String().split(
                            'T',
                          )[0],
                          totalPrice: totalPrice,
                          paymentMethod: "cash",
                          paymentStatus: "pending",
                          status: "pending",
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        await ref
                            .read(bookingViewModelProvider.notifier)
                            .createBooking(booking);

                        final updatedState = ref.read(bookingViewModelProvider);

                        if (updatedState.status == BookingStatus.created) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking Created Successfully ✅"),
                            ),
                          );

                          Navigator.pop(context);
                        } else if (updatedState.status == BookingStatus.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedState.errorMessage ?? "Booking failed ❌",
                              ),
                            ),
                          );
                        }
                      },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C73D2), Color(0xFF845EC2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: bookingState.status == BookingStatus.creating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
