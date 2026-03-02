import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/booking/presentation/pages/booking_history_page.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_card.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_empty_state.dart';
import 'package:hotelspot/features/booking/presentation/widgets/booking_error_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';

class MockBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(status: BookingStatus.initial);

  @override
  Future<void> getMyBookings() async {}
}

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(hotels: []);

  @override
  Future<void> getAllHotels() async {}
}

class MockUserSessionService extends Mock implements UserSessionService {
  @override
  String? getCurrentUserId() => 'user_123';
}

class LoadingBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(status: BookingStatus.loading);

  @override
  Future<void> getMyBookings() async {}
}

class ErrorBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(
    status: BookingStatus.error,
    errorMessage: 'Something went wrong',
  );

  @override
  Future<void> getMyBookings() async {}
}

class NullUserBookingViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => const BookingState(status: BookingStatus.initial);

  @override
  Future<void> getMyBookings() async {}
}

class NullUserSessionService extends Mock implements UserSessionService {
  @override
  String? getCurrentUserId() => null;
}

class BookingWithDataViewModel extends BookingViewModel with Mock {
  @override
  BookingState build() => BookingState(
    status: BookingStatus.loaded,
    bookings: [
      BookingEntity(
        bookingId: 'b1a2c3d4e5f6g7h8',
        userId: 'user_123',
        hotelId: 'h1',
        checkInDate: '2025-06-01',
        checkOutDate: '2025-06-05',
        totalPrice: 8000,
        status: 'confirmed',
        createdAt: DateTime(2025, 5, 20),
        fullName: 'John Doe',
        email: 'john@example.com',
      ),
    ],
  );

  @override
  Future<void> getMyBookings() async {}
}

Widget buildWidget({
  required BookingViewModel bookingNotifier,
  UserSessionService? sessionService,
}) {
  final session = sessionService ?? MockUserSessionService();
  return ProviderScope(
    overrides: [
      bookingViewModelProvider.overrideWith(() => bookingNotifier),
      hotelViewmodelProvider.overrideWith(() => MockHotelViewModel()),
      userSessionServiceProvider.overrideWithValue(session),
    ],
    child: const MaterialApp(home: BookingHistoryPage()),
  );
}

void main() {
  late MockBookingViewModel mock;

  setUp(() => mock = MockBookingViewModel());

  group('rendering', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildWidget(bookingNotifier: mock));
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('shows all tab labels', (tester) async {
      await tester.pumpWidget(buildWidget(bookingNotifier: mock));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('shows empty state when no bookings', (tester) async {
      await tester.pumpWidget(buildWidget(bookingNotifier: mock));
      await tester.pump();
      expect(find.byType(BookingEmptyState), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(bookingNotifier: LoadingBookingViewModel()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows error widget on failure', (tester) async {
      await tester.pumpWidget(
        buildWidget(bookingNotifier: ErrorBookingViewModel()),
      );
      expect(find.byType(BookingErrorState), findsOneWidget);
    });
  });

  group('unauthenticated', () {
    testWidgets('shows login prompt when user is not logged in', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          bookingNotifier: NullUserBookingViewModel(),
          sessionService: NullUserSessionService(),
        ),
      );
      await tester.pump();
      expect(find.text('Please log in to view your bookings'), findsOneWidget);
    });
  });

  group('bookings list', () {
    testWidgets('shows booking cards when bookings exist', (tester) async {
      await tester.pumpWidget(
        buildWidget(bookingNotifier: BookingWithDataViewModel()),
      );
      await tester.pump();
      expect(find.byType(BookingCard), findsWidgets);
    });
  });
}
