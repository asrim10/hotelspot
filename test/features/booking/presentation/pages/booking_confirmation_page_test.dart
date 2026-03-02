import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:hotelspot/screens/main_bottom_screen.dart';

BookingEntity _makeBooking({String? bookingId = 'BK-999'}) => BookingEntity(
  bookingId: bookingId,
  userId: "abc123",
  hotelId: 'hotel_abc',
  fullName: 'Jane Doe',
  email: 'jane@example.com',
  checkInDate: '2025-07-10',
  checkOutDate: '2025-07-14',
  totalPrice: 12000,
  status: 'confirmed',
);

Widget buildWidget({BookingEntity? booking}) => MaterialApp(
  home: BookingConfirmationPage(booking: booking ?? _makeBooking()),
  routes: {'/main': (_) => const MainBottomScreen()},
);

void _setTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('rendering', () {
    testWidgets('shows success icon', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows Booking Confirmed title', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('Booking Confirmed!'), findsOneWidget);
    });

    testWidgets('shows success subtitle message', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(
        find.text('Your booking has been confirmed successfully.'),
        findsOneWidget,
      );
    });

    testWidgets('shows CONTINUE EXPLORING button', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('CONTINUE EXPLORING'), findsOneWidget);
    });
  });

  group('booking info card', () {
    testWidgets('shows booking ID', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('BK-999'), findsOneWidget);
    });

    testWidgets('shows N/A when bookingId is null', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(
        buildWidget(booking: _makeBooking(bookingId: null)),
      );
      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('shows guest name', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('shows email', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('jane@example.com'), findsOneWidget);
    });

    testWidgets('shows check-in date', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('2025-07-10'), findsOneWidget);
    });

    testWidgets('shows check-out date', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('2025-07-14'), findsOneWidget);
    });

    testWidgets('shows total amount', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('NRs.12000'), findsOneWidget);
    });

    testWidgets('shows all info row labels', (tester) async {
      _setTallView(tester);
      await tester.pumpWidget(buildWidget());
      expect(find.text('Booking ID'), findsOneWidget);
      expect(find.text('Guest Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.text('Check Out'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
    });
  });
}
