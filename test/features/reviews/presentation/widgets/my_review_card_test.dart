import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/my_review_card.dart';

ReviewEntity _makeReview({
  double rating = 4.0,
  String comment = 'Great place to stay!',
  DateTime? createdAt,
}) => ReviewEntity(
  userId: 'user_123',
  hotelId: 'hotel_abc',
  fullName: 'John Doe',
  email: 'john@example.com',
  rating: rating,
  comment: comment,
  createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 2)),
);

Widget buildWidget({
  ReviewEntity? review,
  String? hotelName,
  String? imageUrl,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: MyReviewCard(
        review: review ?? _makeReview(),
        hotelName: hotelName,
        imageUrl: imageUrl,
        onEdit: onEdit ?? () {},
        onDelete: onDelete ?? () {},
      ),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget(hotelName: 'Grand Hotel'));
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows fallback Hotel when hotelName is null', (tester) async {
      await tester.pumpWidget(buildWidget(hotelName: null));
      expect(find.text('Hotel'), findsOneWidget);
    });

    testWidgets('shows Verified Stay label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Verified Stay'), findsOneWidget);
    });

    testWidgets('shows review comment', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Great place to stay!'), findsOneWidget);
    });

    testWidgets('shows rating badge with correct value', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 4.0)));
      expect(find.text('4.0'), findsOneWidget);
    });

    testWidgets('shows Edit button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('shows Delete button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('shows hotel icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(buildWidget(imageUrl: null));
      expect(find.byIcon(Icons.hotel), findsOneWidget);
    });

    testWidgets('shows hotel icon when imageUrl is empty', (tester) async {
      await tester.pumpWidget(buildWidget(imageUrl: ''));
      expect(find.byIcon(Icons.hotel), findsOneWidget);
    });

    testWidgets('shows edit and delete icons', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('star rating', () {
    testWidgets('shows 4 filled stars for rating 4.0', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 4.0)));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));
    });

    testWidgets('shows 5 filled stars for rating 5.0', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 5.0)));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets('shows 1 filled star for rating 1.0', (tester) async {
      await tester.pumpWidget(buildWidget(review: _makeReview(rating: 1.0)));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(1));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(4));
    });
  });

  group('time ago', () {
    testWidgets('shows Just now for very recent review', (tester) async {
      await tester.pumpWidget(
        buildWidget(review: _makeReview(createdAt: DateTime.now())),
      );
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('shows hours ago', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          review: _makeReview(
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ),
      );
      expect(find.text('3h ago'), findsOneWidget);
    });

    testWidgets('shows days ago', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          review: _makeReview(
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ),
      );
      expect(find.text('5d ago'), findsOneWidget);
    });

    testWidgets('shows months ago', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          review: _makeReview(
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
          ),
        ),
      );
      expect(find.text('2mo ago'), findsOneWidget);
    });

    testWidgets('shows years ago', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          review: _makeReview(
            createdAt: DateTime.now().subtract(const Duration(days: 400)),
          ),
        ),
      );
      expect(find.text('1y ago'), findsOneWidget);
    });

    testWidgets('shows empty string when createdAt is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(review: _makeReview(createdAt: null)),
      );
      // No crash and no time label rendered
      expect(find.text('Just now'), findsNothing);
    });
  });

  group('callbacks', () {
    testWidgets('calls onEdit when Edit is tapped', (tester) async {
      bool editCalled = false;
      await tester.pumpWidget(buildWidget(onEdit: () => editCalled = true));
      await tester.tap(find.text('Edit'));
      await tester.pump();
      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when Delete is tapped', (tester) async {
      bool deleteCalled = false;
      await tester.pumpWidget(buildWidget(onDelete: () => deleteCalled = true));
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(deleteCalled, isTrue);
    });

    testWidgets('onEdit and onDelete are independent', (tester) async {
      bool editCalled = false;
      bool deleteCalled = false;
      await tester.pumpWidget(
        buildWidget(
          onEdit: () => editCalled = true,
          onDelete: () => deleteCalled = true,
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pump();
      expect(editCalled, isTrue);
      expect(deleteCalled, isFalse);
    });
  });
}
