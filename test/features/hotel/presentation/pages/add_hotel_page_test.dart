import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/hotel/presentation/pages/add_hotel_page.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock class for the ViewModel notifier ---
class MockHotelViewmodel extends Mock implements HotelViewmodel {
  // Add any methods you need to stub here
}

// --- Helper: pumps AddHotelPage inside ProviderScope with overrides ---
Future<void> pumpAddHotelPage(WidgetTester tester, {HotelState? state}) async {
  // Default state: idle, no error
  final hotelState =
      state ??
      HotelState(
        status: HotelStatus.initial,
        errorMessage: null,
        uploadImageName: null,
      );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override the provider so it returns our fake state
        // and does NOT call the real network/backend
        hotelViewmodelProvider.overrideWith(() {
          final mock = MockHotelViewmodel();
          when(() => mock.state).thenReturn(hotelState);
          return mock;
        }),
      ],
      child: MaterialApp(home: AddHotelPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // ---------------------------------------------------------------
  // Test 1: Page renders the AppBar title "Add Hotel"
  // ---------------------------------------------------------------
  testWidgets('Should display "Add Hotel" title in AppBar', (tester) async {
    await pumpAddHotelPage(tester);

    // "Add Hotel" appears twice — AppBar title and bottom ElevatedButton
    // So we scope the search inside AppBar only
    Finder title = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Add Hotel'),
    );
    expect(title, findsOneWidget);
  });

  // ---------------------------------------------------------------
  // Test 2: All section headers are rendered
  // ---------------------------------------------------------------
  testWidgets('Should display all section headers', (tester) async {
    await pumpAddHotelPage(tester);

    // These are the section titles built by _buildSection()
    expect(find.text('Hotel Images'), findsOneWidget);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Pricing & Availability'), findsOneWidget);
  });

  // ---------------------------------------------------------------
  // Test 3: Form validation — required fields show errors on empty submit
  // ---------------------------------------------------------------
  testWidgets(
    'Should show validation errors when Save is tapped with empty fields',
    (tester) async {
      await pumpAddHotelPage(tester);

      // Tap the "Save" TextButton in the AppBar
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // These validation messages come from the validators in the code
      expect(find.text('Please enter hotel name'), findsOneWidget);
      expect(find.text('Please enter address'), findsOneWidget);
      // City and Country use 'Required' as their error
      expect(
        find.text('Required'),
        findsWidgets,
      ); // Price + Rooms + City + Country
    },
  );

  // Test 4: Typing into Hotel Name field works and clears the error
  testWidgets('Should clear Hotel Name validation error after entering text', (
    tester,
  ) async {
    await pumpAddHotelPage(tester);

    // First trigger validation by tapping Save
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter hotel name'), findsOneWidget);

    // Type a valid hotel name (>= 2 chars)
    // Hotel Name is the FIRST TextFormField on the page
    await tester.enterText(find.byType(TextFormField).first, 'Grand Plaza');
    await tester.pumpAndSettle();

    // enterText alone does NOT re-run the validator automatically.
    // Tap Save again to trigger form.validate() which re-checks all fields.
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    // Hotel name error should now be gone (field is valid)
    // Other errors will still show since those fields are empty — that's expected
    expect(find.text('Please enter hotel name'), findsNothing);
  });

  // ---------------------------------------------------------------
  // Test 5: "Add Image" button and the bottom Save ElevatedButton exist
  // ---------------------------------------------------------------
  testWidgets('Should render Add Image area and the bottom Add Hotel button', (
    tester,
  ) async {
    await pumpAddHotelPage(tester);

    // The "Add Image" text inside the image picker placeholder
    expect(find.text('Add Image'), findsOneWidget);

    // The bottom ElevatedButton says "Add Hotel" (not uploading state)
    expect(find.widgetWithText(ElevatedButton, 'Add Hotel'), findsOneWidget);
  });
}
