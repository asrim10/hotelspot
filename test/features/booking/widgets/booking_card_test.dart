import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_card.dart';
import 'package:hotelspot/features/booking/presentation/widgets/review_button.dart';

BookingEntity _makeBooking({
  String status = 'confirmed',
  String? bookingId = 'abc12345',
  String? paymentStatus = 'paid',
  String? paymentMethod = 'khalti',
}) => BookingEntity(
  bookingId: bookingId,
  userId: "abc123",
  hotelId: 'hotel_abc',
  fullName: 'John Doe',
  email: 'john@example.com',
  checkInDate: '2025-06-01',
  checkOutDate: '2025-06-05',
  totalPrice: 8000,
  status: status,
  paymentStatus: paymentStatus,
  paymentMethod: paymentMethod,
);

Widget buildWidget({
  BookingEntity? booking,
  String? hotelName,
  String? imageUrl,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BookingCard(
        booking: booking ?? _makeBooking(),
        hotelName: hotelName,
        imageUrl: imageUrl,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows hotel name when provided', (tester) async {
      await tester.pumpWidget(buildWidget(hotelName: 'Grand Hotel'));
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows fullName as fallback when hotelName is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(hotelName: null));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows booking ID prefix', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('#ABC12345'), findsOneWidget);
    });

    testWidgets('shows N/A when bookingId is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(bookingId: null)),
      );
      expect(find.text('#N/A'), findsOneWidget);
    });

    testWidgets('shows check-in date', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('2025-06-01'), findsOneWidget);
    });

    testWidgets('shows check-out date', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('2025-06-05'), findsOneWidget);
    });

    testWidgets('shows total price', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('NRs.8000'), findsOneWidget);
    });

    testWidgets('shows hotel icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(buildWidget(imageUrl: null));
      expect(find.byIcon(Icons.hotel), findsOneWidget);
    });
  });

  group('status badge', () {
    testWidgets('shows Confirmed badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'confirmed')),
      );
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows Cancelled badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'cancelled')),
      );
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('shows Checked In badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'checked_in')),
      );
      expect(find.text('Checked In'), findsOneWidget);
    });

    testWidgets('shows Checked Out badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'checked_out')),
      );
      expect(find.text('Checked Out'), findsOneWidget);
    });
  });

  group('payment info', () {
    testWidgets('shows payment paid status', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Payment: Paid'), findsOneWidget);
    });

    testWidgets('shows payment pending status', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(paymentStatus: 'pending')),
      );
      expect(find.text('Payment: Pending'), findsOneWidget);
    });

    testWidgets('shows payment method', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('· Khalti'), findsOneWidget);
    });

    testWidgets('hides payment row when paymentStatus is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(paymentStatus: null)),
      );
      expect(find.textContaining('Payment:'), findsNothing);
    });

    testWidgets('hides payment method when paymentMethod is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(paymentMethod: null)),
      );
      expect(find.textContaining('·'), findsNothing);
    });

    testWidgets('shows check circle icon for paid status', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows schedule icon for pending status', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(paymentStatus: 'pending')),
      );
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });
  });

  group('review button', () {
    testWidgets('shows ReviewButton for confirmed booking', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'confirmed')),
      );
      expect(find.byType(ReviewButton), findsOneWidget);
    });

    testWidgets('shows ReviewButton for checked_out booking', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'checked_out')),
      );
      expect(find.byType(ReviewButton), findsOneWidget);
    });

    testWidgets('hides ReviewButton for cancelled booking', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'cancelled')),
      );
      expect(find.byType(ReviewButton), findsNothing);
    });

    testWidgets('hides ReviewButton for checked_in booking', (tester) async {
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(status: 'checked_in')),
      );
      expect(find.byType(ReviewButton), findsNothing);
    });
  });

  group('tap callback', () {
    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
