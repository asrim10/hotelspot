import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/presentation/pages/profile_page.dart';
import 'package:hotelspot/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';
import 'package:hotelspot/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';

class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState(
    status: AuthStatus.authenticated,
    authEntity: AuthEntity(
      fullName: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
      imageUrl: null,
    ),
  );

  @override
  Future<void> getProfile() async {}
}

class LoadingAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => const AuthState(status: AuthStatus.profileLoading);

  @override
  Future<void> getProfile() async {}
}

class MockTokenService extends Mock implements TokenService {}

Widget buildWidget({required AuthViewModel notifier}) {
  final mockToken = MockTokenService();
  when(() => mockToken.removeToken()).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(() => notifier),
      tokenServiceProvider.overrideWithValue(mockToken),
    ],
    child: const MaterialApp(home: ProfilePage()),
  );
}

void main() {
  late MockAuthViewModel mock;

  setUp(() => mock = MockAuthViewModel());

  group('rendering', () {
    testWidgets('shows user full name', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows username with @ prefix', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('@johndoe'), findsOneWidget);
    });

    testWidgets('shows user email', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('shows all menu items', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Booking History'), findsOneWidget);
      expect(find.text('My Reviews'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows person icon when no image url', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when profile is loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingAuthViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides menu items when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingAuthViewModel()));
      expect(find.text('Edit Profile'), findsNothing);
      expect(find.text('Logout'), findsNothing);
    });
  });

  group('logout dialog', () {
    testWidgets('shows logout dialog on tap', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    });

    testWidgets('dismisses dialog on cancel', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to logout?'), findsNothing);
    });

    testWidgets('navigates to LoginPage after logout', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
