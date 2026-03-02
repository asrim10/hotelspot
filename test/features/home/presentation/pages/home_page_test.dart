import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/hotel/presentation/pages/all_hotels_page.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/presentation/widgets/hotel_card.dart';

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(hotels: []);

  @override
  Future<void> getAllHotels() async {}
}

class LoadingHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(status: HotelStatus.loading);

  @override
  Future<void> getAllHotels() async {}
}

class ErrorHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(
    status: HotelStatus.error,
    errorMessage: 'Failed to load hotels',
  );

  @override
  Future<void> getAllHotels() async {}
}

class LoadedHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => HotelState(
    status: HotelStatus.loaded,
    hotels: [
      HotelEntity(
        hotelId: 'h1',
        hotelName: 'Grand Hotel',
        price: 2000,
        rating: 4.5,
        imageUrl: null,
        city: 'Kathmandu',
        country: 'Nepal',
        address: '123 Main Street',
        availableRooms: 5,
      ),
    ],
  );

  @override
  Future<void> getAllHotels() async {}
}

Widget buildWidget({HotelViewmodel? notifier}) {
  return ProviderScope(
    overrides: [
      hotelViewmodelProvider.overrideWith(
        () => notifier ?? MockHotelViewModel(),
      ),
    ],
    child: const MaterialApp(home: AllHotelsPage()),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('All Hotels'), findsOneWidget);
    });

    testWidgets('shows empty state when no hotels', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.text('No hotels available'), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingHotelViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorHotelViewModel()));
      expect(find.text('Failed to load hotels'), findsOneWidget);
    });
  });

  group('loaded state', () {
    testWidgets('shows hotel cards', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedHotelViewModel()));
      await tester.pump();
      expect(find.byType(HotelCard), findsOneWidget);
    });

    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedHotelViewModel()));
      await tester.pump();
      expect(find.text('Grand Hotel'), findsOneWidget);
    });
  });
}
