import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';
import 'package:hotelspot/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => const AuthState(status: AuthStatus.initial);

  @override
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {}
}

class _UpdatingAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => const AuthState(status: AuthStatus.profileUpdating);

  @override
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {}
}

class _ErrorAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() =>
      const AuthState(status: AuthStatus.error, errorMessage: 'Update failed');

  @override
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {}
}

final _mockUser = AuthEntity(
  fullName: 'Jane Doe',
  username: 'janedoe',
  email: 'jane@example.com',
  imageUrl: null,
);

const _unset = Object();

Widget buildWidget({Object? user = _unset, AuthViewModel? authNotifier}) {
  final resolvedUser = user == _unset ? _mockUser : user as AuthEntity?;

  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(
        () => authNotifier ?? MockAuthViewModel(),
      ),
    ],
    child: MaterialApp(home: EditProfilePage(user: resolvedUser)),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows Edit Profile title in app bar', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('shows Tap to change photo label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Tap to change photo'), findsOneWidget);
    });

    testWidgets('shows camera icon on avatar overlay', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('shows Full Name field pre-filled from user', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.widgetWithText(TextFormField, 'Jane Doe'), findsOneWidget);
    });

    testWidgets('shows Username field pre-filled from user', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.widgetWithText(TextFormField, 'janedoe'), findsOneWidget);
    });

    testWidgets('shows Phone Number field label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Phone Number (optional)'), findsOneWidget);
    });

    testWidgets('shows Save Changes button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('shows person icon when no image url', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('form validation', () {
    testWidgets('shows required error when Full Name is cleared', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jane Doe'),
        '',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('shows min length error for Full Name < 2 chars', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jane Doe'),
        'A',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('Min 2 characters'), findsOneWidget);
    });

    testWidgets('shows required error when Username is cleared', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.widgetWithText(TextFormField, 'janedoe'), '');
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('does not show errors when fields are valid', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('Required'), findsNothing);
      expect(find.text('Min 2 characters'), findsNothing);
    });
  });

  group('loading state', () {
    testWidgets('shows spinner when profileUpdating', (tester) async {
      await tester.pumpWidget(
        buildWidget(authNotifier: _UpdatingAuthViewModel()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets('Save Changes button is disabled when updating', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(authNotifier: _UpdatingAuthViewModel()),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('image picker bottom sheet', () {
    testWidgets('tapping avatar shows bottom sheet', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      expect(find.text('Choose Photo'), findsOneWidget);
      expect(find.text('Take a Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('bottom sheet dismisses after tapping Take a Photo', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a Photo'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Photo'), findsNothing);
    });
  });

  group('null user', () {
    testWidgets('renders correctly when user is null', (tester) async {
      await tester.pumpWidget(buildWidget(user: null));
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Full Name field is empty when user is null', (tester) async {
      await tester.pumpWidget(buildWidget(user: null));
      final controllers = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .map((f) => f.controller?.text ?? '')
          .toList();
      expect(controllers.first, '');
    });
  });
}
