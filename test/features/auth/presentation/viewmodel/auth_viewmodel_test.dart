import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/login_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/register_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';

// Mocks
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

// Fakes
class FakeRegisterUsecaseParams extends Fake implements RegisterUsecaseParams {}

class FakeLoginUsecaseParams extends Fake implements LoginUsecaseParams {}

class FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetProfileUsecase mockGetProfileUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late ProviderContainer container;
  late AuthEntity tAuthEntity;

  setUpAll(() {
    registerFallbackValue(FakeRegisterUsecaseParams());
    registerFallbackValue(FakeLoginUsecaseParams());
    registerFallbackValue(FakeUpdateProfileParams());
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetProfileUsecase = MockGetProfileUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();

    tAuthEntity = AuthEntity(
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      username: 'johndoe',
      password: 'password123',
      confirmPassword: 'password123',
    );

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getProfileUsecaseProvider.overrideWithValue(mockGetProfileUsecase),
        updateProfileUsecaseProvider.overrideWithValue(
          mockUpdateProfileUsecase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  AuthViewModel readViewModel() =>
      container.read(authViewModelProvider.notifier);

  AuthState readState() => container.read(authViewModelProvider);

  group('AuthViewModel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(AuthStatus.initial));
        expect(readState().authEntity, isNull);
        expect(readState().errorMessage, isNull);
        expect(readState().imageVersion, equals(0));
      });
    });

    group('register', () {
      test('should emit loading then registered status on success', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        await readViewModel().register(
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          username: 'johndoe',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(readState().status, equals(AuthStatus.registered));
      });

      test('should emit error status when register fails', () async {
        const tFailure = ApiFailure(message: 'Email already exists');
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().register(
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          username: 'johndoe',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(readState().status, equals(AuthStatus.error));
        expect(readState().errorMessage, equals('Email already exists'));
      });

      test('should emit error status when register returns false', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(false));

        await readViewModel().register(
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          username: 'johndoe',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(readState().status, equals(AuthStatus.error));
        expect(readState().errorMessage, equals('Registration failed'));
      });
    });

    group('login', () {
      test(
        'should emit loading then authenticated status on success',
        () async {
          when(
            () => mockLoginUsecase(any()),
          ).thenAnswer((_) async => Right(tAuthEntity));

          await readViewModel().login(
            email: 'johndoe@email.com',
            password: 'password123',
          );

          expect(readState().status, equals(AuthStatus.authenticated));
          expect(readState().authEntity, equals(tAuthEntity));
        },
      );

      test('should emit error status when login fails', () async {
        const tFailure = ApiFailure(message: 'Invalid credentials');
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().login(
          email: 'johndoe@email.com',
          password: 'wrongpassword',
        );

        expect(readState().status, equals(AuthStatus.error));
        expect(readState().errorMessage, equals('Invalid credentials'));
      });
    });

    group('getProfile', () {
      test(
        'should emit profileLoading then profileLoaded status on success',
        () async {
          when(
            () => mockGetProfileUsecase(),
          ).thenAnswer((_) async => Right(tAuthEntity));

          await readViewModel().getProfile();

          expect(readState().status, equals(AuthStatus.profileLoaded));
          expect(readState().authEntity, equals(tAuthEntity));
        },
      );

      test('should emit error status when getProfile fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load profile');
        when(
          () => mockGetProfileUsecase(),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getProfile();

        expect(readState().status, equals(AuthStatus.error));
        expect(readState().errorMessage, equals('Failed to load profile'));
      });
    });

    group('updateProfile', () {
      test(
        'should emit profileUpdating then profileUpdated status on success',
        () async {
          when(
            () => mockUpdateProfileUsecase(any()),
          ).thenAnswer((_) async => Right(tAuthEntity));

          await readViewModel().updateProfile(fullName: 'Jane Doe');

          expect(readState().status, equals(AuthStatus.profileUpdated));
          expect(readState().authEntity, equals(tAuthEntity));
        },
      );

      test(
        'should increment imageVersion on successful profile update',
        () async {
          when(
            () => mockUpdateProfileUsecase(any()),
          ).thenAnswer((_) async => Right(tAuthEntity));

          final initialVersion = readState().imageVersion;
          await readViewModel().updateProfile(fullName: 'Jane Doe');

          expect(readState().imageVersion, equals(initialVersion + 1));
        },
      );

      test('should emit error status when updateProfile fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update profile');
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updateProfile(fullName: 'Jane Doe');

        expect(readState().status, equals(AuthStatus.error));
        expect(readState().errorMessage, equals('Failed to update profile'));
      });
    });
  });
}
