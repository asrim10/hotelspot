import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/hotel/presentation/pages/hotel_details_page.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/favourites/presentation/state/favourite_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(status: HotelStatus.initial);

  @override
  Future<void> getHotelById(String id) async {}
}

class LoadingHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(status: HotelStatus.loading);

  @override
  Future<void> getHotelById(String id) async {}
}

class ErrorHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(
    status: HotelStatus.error,
    errorMessage: 'Failed to load hotel',
  );

  @override
  Future<void> getHotelById(String id) async {}
}

class LoadedHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => HotelState(
    status: HotelStatus.loaded,
    selectedHotel: HotelEntity(
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
  );

  @override
  Future<void> getHotelById(String id) async {}
}

class MockFavouriteViewModel extends FavouriteViewModel with Mock {
  @override
  FavouriteState build() => const FavouriteState(favourites: []);
}

class MockReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(reviews: []);

  @override
  Future<void> getReviewsByHotelId(String hotelId) async {}
}

Widget buildWidget({required HotelViewmodel notifier}) {
  return ProviderScope(
    overrides: [
      hotelViewmodelProvider.overrideWith(() => notifier),
      favouriteViewModelProvider.overrideWith(() => MockFavouriteViewModel()),
      reviewViewmodelProvider.overrideWith(() => MockReviewViewModel()),
    ],
    child: const MaterialApp(home: HotelDetailsPage(hotelId: 'h1')),
  );
}

void main() {
  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingHotelViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorHotelViewModel()));
      expect(find.text('Failed to load hotel'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorHotelViewModel()));
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });
  });

  group('empty state', () {
    testWidgets('shows hotel not found when no hotel selected', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: MockHotelViewModel()));
      await tester.pump();
      expect(find.text('Hotel not found'), findsOneWidget);
    });
  });

  group('loaded state', () {
    testWidgets('shows Book Now button when hotel is loaded', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedHotelViewModel()));
      await tester.pump();
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('shows hotel name when loaded', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedHotelViewModel()));
      await tester.pump();
      expect(find.text('Grand Hotel'), findsOneWidget);
    });
  });
}
