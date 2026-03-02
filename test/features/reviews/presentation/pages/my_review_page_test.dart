import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/my_review_card.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/reviews/presentation/pages/my_review_page.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

class MockReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState();

  @override
  Future<void> getMyReviews() async {}

  @override
  Future<void> deleteReview({
    required String reviewId,
    required String hotelId,
  }) async {}
}

class LoadingReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(status: ReviewStatus.loading);

  @override
  Future<void> getMyReviews() async {}
}

class ErrorReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(
    status: ReviewStatus.error,
    errorMessage: 'Failed to load reviews',
  );

  @override
  Future<void> getMyReviews() async {}
}

class LoadedReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => ReviewState(
    status: ReviewStatus.loaded,
    myReviews: [
      ReviewEntity(
        reviewId: 'r1',
        hotelId: 'h1',
        userId: 'u1',
        rating: 4.5,
        comment: 'Great place to stay!',
        fullName: 'Asrim Suwal',
        email: 'asrim@example.com',
      ),
    ],
  );

  @override
  Future<void> getMyReviews() async {}

  @override
  Future<void> deleteReview({
    required String reviewId,
    required String hotelId,
  }) async {}
}

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(hotels: []);

  @override
  Future<void> getAllHotels() async {}

  @override
  Future<void> getHotelById(String id) async {}
}

Widget buildWidget({ReviewViewmodel? notifier}) {
  return ProviderScope(
    overrides: [
      reviewViewmodelProvider.overrideWith(
        () => notifier ?? MockReviewViewModel(),
      ),
      hotelViewmodelProvider.overrideWith(() => MockHotelViewModel()),
    ],
    child: const MaterialApp(home: MyReviewsPage()),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('My Reviews'), findsOneWidget);
    });

    testWidgets('shows empty state when no reviews', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.text('No reviews yet'), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingReviewViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorReviewViewModel()));
      expect(find.text('Failed to load reviews'), findsOneWidget);
    });

    testWidgets('shows retry button', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: ErrorReviewViewModel()));
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('loaded state', () {
    testWidgets('shows review cards when reviews exist', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedReviewViewModel()));
      await tester.pump();
      expect(find.byType(MyReviewCard), findsOneWidget);
    });
  });

  group('delete dialog', () {
    testWidgets('shows delete dialog on delete tap', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedReviewViewModel()));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete Review?'), findsOneWidget);
    });

    testWidgets('dismisses dialog on cancel', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadedReviewViewModel()));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Review?'), findsNothing);
    });
  });
}
