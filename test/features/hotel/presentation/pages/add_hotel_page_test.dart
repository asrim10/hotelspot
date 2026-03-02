import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/hotel/presentation/pages/add_hotel_page.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';

class MockHotelViewModel extends HotelViewmodel with Mock {
  @override
  HotelState build() => const HotelState(status: HotelStatus.initial);

  @override
  Future<void> createHotel({
    required String hotelName,
    required String address,
    required String city,
    required String country,
    required double rating,
    String? description,
    required double price,
    required int availableRooms,
    String? imageUrl,
  }) async {}

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
    child: const MaterialApp(home: AddHotelPage()),
  );
}

Future<void> tapSave(WidgetTester tester) async {
  final btn = find.widgetWithText(ElevatedButton, 'Add Hotel');
  await tester.ensureVisible(btn);
  await tester.tap(btn);
  await tester.pump();
}

void main() {
  group('rendering', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Add Hotel'), findsWidgets);
    });

    testWidgets('shows all section titles', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Pricing & Availability'), findsOneWidget);
    });

    testWidgets('shows add image button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Add Image'), findsOneWidget);
    });

    testWidgets('shows save button in app bar', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
    });
  });

  group('validation', () {
    testWidgets('shows errors on empty submit', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tapSave(tester);
      expect(find.text('Please enter hotel name'), findsOneWidget);
      expect(find.text('Please enter address'), findsOneWidget);
    });

    testWidgets('shows error for short hotel name', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tapSave(tester);
      expect(
        find.text('Hotel name must be at least 2 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for short address', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField).at(2), 'abc');
      await tapSave(tester);
      expect(
        find.text('Address must be at least 5 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows required errors for city and country', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tapSave(tester);
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('shows snackbar when no image is uploaded', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'Grand Hotel');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '123 Main Street',
      );
      await tester.enterText(find.byType(TextFormField).at(3), 'Kathmandu');
      await tester.enterText(find.byType(TextFormField).at(4), 'Nepal');
      await tester.enterText(find.byType(TextFormField).at(5), '2000');
      await tester.enterText(find.byType(TextFormField).at(6), '5');
      await tapSave(tester);
      await tester.pumpAndSettle();
      expect(find.text('Please select and upload an image'), findsOneWidget);
    });
  });

  group('rating slider', () {
    testWidgets('shows rating slider', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows no rating text by default', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('No rating'), findsOneWidget);
    });
  });
}
