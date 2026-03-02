import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/reviews/presentation/pages/write_review_page.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

class MockReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState();

  @override
  Future<void> createReview({
    required String hotelId,
    required double rating,
    required String comment,
  }) async {}
}

class LoadingReviewViewModel extends ReviewViewmodel with Mock {
  @override
  ReviewState build() => const ReviewState(status: ReviewStatus.loading);

  @override
  Future<void> createReview({
    required String hotelId,
    required double rating,
    required String comment,
  }) async {}
}

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(status: HotelStatus.initial);

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
    child: const MaterialApp(
      home: WriteReviewPage(hotelId: 'h1', hotelName: 'Grand Hotel'),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Write a Review'), findsOneWidget);
    });

    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows rating and experience labels', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Your Rating'), findsOneWidget);
      expect(find.text('Your Experience'), findsOneWidget);
    });

    testWidgets('shows submit button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('SUBMIT REVIEW'), findsOneWidget);
    });

    testWidgets('shows verified stay label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Verified Stay'), findsOneWidget);
    });
  });

  group('validation', () {
    testWidgets('shows snackbar when no rating selected', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.ensureVisible(find.text('SUBMIT REVIEW'));
      await tester.tap(find.text('SUBMIT REVIEW'));
      await tester.pumpAndSettle();
      expect(find.text('Please select a rating'), findsOneWidget);
    });

    testWidgets('shows error for short comment', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField), 'hi');
      await tester.pump();
      final form = tester.widget<Form>(find.byType(Form));
      (form.key as GlobalKey<FormState>).currentState!.validate();
      await tester.pump();
      expect(
        find.text('Comment must be at least 5 characters'),
        findsOneWidget,
      );
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingReviewViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides submit text when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingReviewViewModel()));
      expect(find.text('SUBMIT REVIEW'), findsNothing);
    });
  });
}
