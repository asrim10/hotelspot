import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/booking/presentation/pages/booking_details_page.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/payment/presentation/state/payment_state.dart';
import 'package:hotelspot/features/payment/presentation/view_model/payment_viewmodel.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';

class MockBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(status: BookingStatus.initial);

  @override
  Future<void> createBooking(booking) async {}
}

class MockPaymentViewModel extends PaymentViewmodel with Mock {
  @override
  PaymentState build() => const PaymentState(status: PaymentStatus.initial);
}

class MockUserSessionService extends Mock implements UserSessionService {
  @override
  String? getCurrentUserId() => 'user_123';

  @override
  String? getCurrentUserFullName() => 'John Doe';

  @override
  String? getCurrentUserEmail() => 'john@example.com';
}

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

Widget buildWidget({BookingViewModel? bookingNotifier}) {
  return ProviderScope(
    overrides: [
      bookingViewModelProvider.overrideWith(
        () => bookingNotifier ?? MockBookingViewModel(),
      ),
      paymentViewmodelProvider.overrideWith(() => MockPaymentViewModel()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
    ],
    child: MaterialApp(
      home: BookingDetailsPage(
        hotel: mockHotel,
        checkInDate: DateTime(2025, 6, 1),
        checkOutDate: DateTime(2025, 6, 5),
      ),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows booking summary title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Booking Summary'), findsOneWidget);
    });

    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows check-in and check-out dates', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Jun 1, 2025'), findsOneWidget);
      expect(find.text('Jun 5, 2025'), findsOneWidget);
    });

    testWidgets('shows number of days', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('4 Days'), findsOneWidget);
    });

    testWidgets('shows total amount', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.textContaining('8000'), findsWidgets);
    });

    testWidgets('shows pay with khalti button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('PAY WITH KHALTI'), findsOneWidget);
    });

    testWidgets('shows pay at hotel button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('PAY AT HOTEL (CASH)'), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when booking is being created', (tester) async {
      final loadingVm = _CreatingBookingViewModel();
      await tester.pumpWidget(buildWidget(bookingNotifier: loadingVm));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _CreatingBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(status: BookingStatus.creating);

  @override
  Future<void> createBooking(booking) async {}
}
