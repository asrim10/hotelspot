import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/favourites/presentation/pages/favourite_page.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_empty_state.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_stub_card.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/favourites/presentation/state/favourite_state.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';

class MockFavouriteViewModel extends FavouriteViewModel with Mock {
  @override
  FavouriteState build() => const FavouriteState(favourites: []);

  @override
  Future<void> getMyFavourites(String userId) async {}
}

class LoadingFavouriteViewModel extends FavouriteViewModel with Mock {
  @override
  FavouriteState build() =>
      const FavouriteState(status: FavouriteStatus.loading);

  @override
  Future<void> getMyFavourites(String userId) async {}
}

class ErrorFavouriteViewModel extends FavouriteViewModel with Mock {
  @override
  FavouriteState build() => const FavouriteState(
    status: FavouriteStatus.error,
    errorMessage: 'Failed to load favourites',
  );

  @override
  Future<void> getMyFavourites(String userId) async {}
}

class LoadedFavouriteViewModel extends FavouriteViewModel with Mock {
  @override
  FavouriteState build() => FavouriteState(
    status: FavouriteStatus.loaded,
    favourites: [
      FavouriteEntity(
        favouriteId: 'f1a2b3c4',
        userId: 'user_123',
        hotelId: 'h1a2b3c4',
      ),
    ],
  );

  @override
  Future<void> getMyFavourites(String userId) async {}

  @override
  Future<void> removeFromFavourites(String favouriteId) async {}
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

Widget buildWidget({FavouriteViewModel? notifier}) {
  return ProviderScope(
    overrides: [
      favouriteViewModelProvider.overrideWith(
        () => notifier ?? MockFavouriteViewModel(),
      ),
      hotelViewmodelProvider.overrideWith(() => MockHotelViewModel()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
    ],
    child: const MaterialApp(home: FavouritesPage()),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows My Favourites title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('My Favourites'), findsOneWidget);
    });

    testWidgets('shows favourites count badge', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(notifier: LoadingFavouriteViewModel()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorFavouriteViewModel()));
      expect(find.text('Failed to load favourites'), findsOneWidget);
    });
  });

  group('empty state', () {
    testWidgets('shows empty state when no favourites', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.byType(FavouritesEmptyState), findsOneWidget);
    });
  });

  group('loaded state', () {
    testWidgets('shows correct favourites count', (tester) async {
      await tester.pumpWidget(
        buildWidget(notifier: LoadedFavouriteViewModel()),
      );
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows stub card when hotel not found', (tester) async {
      await tester.pumpWidget(
        buildWidget(notifier: LoadedFavouriteViewModel()),
      );
      await tester.pump();
      expect(find.byType(FavouriteStubCard), findsOneWidget);
    });
  });
}
