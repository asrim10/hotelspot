import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/auth/presentation/pages/login_page.dart';
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
    child: const MaterialApp(home: LoginPage()),
  );
}

Future<void> tapLogin(WidgetTester tester) async {
  final btn = find.widgetWithText(OutlinedButton, 'Login');
  await tester.ensureVisible(btn);
  await tester.tap(btn);
  await tester.pump();
}

void main() {
  late MockAuthViewModel mock;

  setUp(() => mock = MockAuthViewModel());

  group('rendering', () {
    testWidgets('Renders 2 text fields', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Shows email and password labels', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.text('Email:'), findsOneWidget);
      expect(find.text('Password:'), findsOneWidget);
    });

    testWidgets('Shows login button', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(find.widgetWithText(OutlinedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Shows register link', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('Register'),
        ),
        findsOneWidget,
      );
    });
  });

  group('validation', () {
    testWidgets('Shows errors on empty submit', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tapLogin(tester);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.enterText(find.byType(TextFormField).at(0), 'bad-email');
      await tapLogin(tester);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows error for short password', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tapLogin(tester);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  group('password visibility', () {
    testWidgets('Password is obscured by default', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(fields[1].obscureText, isTrue);
    });

    testWidgets('Tapping eye icon reveals password', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();
      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(fields[1].obscureText, isFalse);
    });
  });

  group('loading state', () {
    testWidgets('Shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingAuthViewModel()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Login button is disabled when loading', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: LoadingAuthViewModel()));
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('navigation', () {
    testWidgets('Register link is present and tappable', (tester) async {
      await tester.pumpWidget(buildWidget(notifier: mock));
      final registerLink = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Register'),
      );
      await tester.ensureVisible(registerLink);
      expect(registerLink, findsOneWidget);

      final richText = tester.widget<RichText>(registerLink);
      final span = richText.text as TextSpan;
      final registerSpan = span.children!.last as TextSpan;
      expect(registerSpan.recognizer, isNotNull);
    });
  });
}
