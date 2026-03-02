import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/auth/presentation/pages/register_page.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';
import 'package:hotelspot/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => const AuthState(status: AuthStatus.initial);
}

class LoadingAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => const AuthState(status: AuthStatus.loading);
}

Widget buildWidget({required AuthViewModel notifier}) {
  return ProviderScope(
    overrides: [authViewModelProvider.overrideWith(() => notifier)],
    child: const MaterialApp(home: RegisterPage()),
  );
}

Future<void> tapRegister(WidgetTester tester) async {
  final btn = find.widgetWithText(OutlinedButton, 'Register');
  await tester.ensureVisible(btn);
  await tester.tap(btn);
  await tester.pump();
}

void main() {
  late MockAuthViewModel mock;

  setUp(() => mock = MockAuthViewModel());

  group('rendering', () {
    testWidgets('Renders 4 text fields', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('Shows all field labels', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('Full Name:'), findsOneWidget);
      expect(find.text('Email:'), findsOneWidget);
      expect(find.text('Password:'), findsOneWidget);
      expect(find.text('Confirm Password:'), findsOneWidget);
    });

    testWidgets('Shows register button', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.widgetWithText(OutlinedButton, 'Register'), findsOneWidget);
    });

    testWidgets('Shows login link', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText && widget.text.toPlainText().contains('Login'),
        ),
        findsOneWidget,
      );
    });
  });

  group('validation', () {
    testWidgets('Shows errors on empty submit', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tapRegister(tester);
      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');
      await tapRegister(tester);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.enterText(find.byType(TextFormField).at(2), 'pass123');
      await tester.enterText(find.byType(TextFormField).at(3), 'other123');
      await tapRegister(tester);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('password visibility', () {
    testWidgets('Password is obscured by default', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(fields[2].obscureText, isTrue);
      expect(fields[3].obscureText, isTrue);
    });

    testWidgets('Tapping eye icon reveals password', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();
      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(fields[2].obscureText, isFalse);
    });
  });

  group('loading state', () {
    testWidgets('Shows spinner when loading', (tester) async {
      final loadingMock = LoadingAuthViewModel();
      await tester.pumpWidget(buildWidget(notifier: loadingMock));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
