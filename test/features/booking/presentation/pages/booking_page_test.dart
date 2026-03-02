import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelspot/features/booking/presentation/pages/booking_page.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

final mockHotel = HotelEntity(
  hotelName: 'Grand Hotel',
  price: 2000,
  rating: 4.5,
  imageUrl: null,
  city: 'Kathmandu',
  country: 'Nepal',
  address: '123 Main Street',
  availableRooms: 5,
);
Widget buildWidget() {
  return ProviderScope(
    child: MaterialApp(home: BookingPage(hotel: mockHotel)),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows price per night', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.textContaining('2000'), findsOneWidget);
    });

    testWidgets('shows check-in and check-out fields', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Check-out'), findsOneWidget);
    });

    testWidgets('shows continue button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('summary is hidden before dates are selected', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Nights'), findsNothing);
      expect(find.text('Total Price'), findsNothing);
    });
  });
}
