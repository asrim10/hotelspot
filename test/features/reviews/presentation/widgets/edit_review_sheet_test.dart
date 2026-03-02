import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/star_rating_selector.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/edit_review_sheet.dart';

class MockReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(status: ReviewStatus.initial);

  @override
  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required String hotelId,
    required String fullName,
    required String email,
    required double rating,
    required String comment,
  }) async {}

  @override
  Future<void> getMyReviews() async {}
}

class _LoadingReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(status: ReviewStatus.loading);

  @override
  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required String hotelId,
    required String fullName,
    required String email,
    required double rating,
    required String comment,
  }) async {}

  @override
  Future<void> getMyReviews() async {}
}

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  Future<void> getHotelById(String hotelId) async {}
}

ReviewEntity _makeReview({
  String reviewId = 'review_001',
  double rating = 4.0,
  String comment = 'Really loved the stay here!',
}) => ReviewEntity(
  reviewId: reviewId,
  userId: 'user_123',
  hotelId: 'hotel_abc',
  fullName: 'John Doe',
  email: 'john@example.com',
  rating: rating,
  comment: comment,
  createdAt: DateTime.now().subtract(const Duration(days: 2)),
);

Widget buildWidget({
  ReviewEntity? review,
  ReviewViewmodel? reviewNotifier,
  HotelViewmodel? hotelNotifier,
}) {
  return ProviderScope(
    overrides: [
      reviewViewmodelProvider.overrideWith(
        () => reviewNotifier ?? MockReviewViewModel(),
      ),
      hotelViewmodelProvider.overrideWith(
        () => hotelNotifier ?? MockHotelViewModel(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: EditReviewSheet(review: review ?? _makeReview())),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows Edit Review title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Edit Review'), findsOneWidget);
    });

    testWidgets('shows SAVE CHANGES button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('SAVE CHANGES'), findsOneWidget);
    });

    testWidgets('shows comment pre-filled from review', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.widgetWithText(TextFormField, 'Really loved the stay here!'),
        findsOneWidget,
      );
    });

    testWidgets('shows hint text when comment is empty', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(comment: '')));
      expect(find.text('Update your experience...'), findsOneWidget);
    });

    testWidgets('shows StarRatingSelector', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(StarRatingSelector), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(reviewNotifier: _LoadingReviewViewModel()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SAVE CHANGES'), findsNothing);
    });

    testWidgets('tap is no-op when loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(reviewNotifier: _LoadingReviewViewModel()),
      );
      await tester.tap(find.byType(GestureDetector).last, warnIfMissed: false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('form validation', () {
    testWidgets('shows error when comment is too short', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField), 'Hi');
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();
      expect(
        find.text('Comment must be at least 5 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when comment is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField), '');
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();
      expect(
        find.text('Comment must be at least 5 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when rating is 0', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 0)));
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();
      expect(find.text('Please select a rating'), findsOneWidget);
    });

    testWidgets('no validation error when comment is valid', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();
      expect(find.text('Comment must be at least 5 characters'), findsNothing);
    });
  });

  group('initial state', () {
    testWidgets('rating is pre-set from review', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 3.0)));
      final selector = tester.widget<StarRatingSelector>(
        find.byType(StarRatingSelector),
      );
      expect(selector.selectedRating, 3);
    });

    testWidgets('rating rounds correctly for decimal value', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 4.6)));
      final selector = tester.widget<StarRatingSelector>(
        find.byType(StarRatingSelector),
      );
      expect(selector.selectedRating, 5);
    });
  });
}
