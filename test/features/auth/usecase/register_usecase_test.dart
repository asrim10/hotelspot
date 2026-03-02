import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/domain/repositories/auth_repository.dart';
import 'package:hotelspot/features/auth/domain/usecases/register_usecase.dart';

// Mock
class MockAuthRepository extends Mock implements IAuthRepository {}

// Fake (needed for registerFallbackValue since register() takes AuthEntity)
class FakeAuthEntity extends Fake implements AuthEntity {}

void main() {
  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;
  late RegisterUsecaseParams tParams;

  setUpAll(() {
    registerFallbackValue(FakeAuthEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
    tParams = const RegisterUsecaseParams(
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      phoneNumber: '09123456789',
      username: 'johndoe',
      password: 'password123',
      confirmPassword: 'password123',
    );
  });

  group('RegisterUsecase', () {
    // Returns true on successful registration
    test('should return true when registration is successful', () async {
      when(
        () => mockAuthRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await registerUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockAuthRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Registration failed');
      when(
        () => mockAuthRepository.register(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await registerUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockAuthRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // Passes correct AuthEntity built from params to repository
    test(
      'should call repository with correct AuthEntity from params',
      () async {
        when(
          () => mockAuthRepository.register(any()),
        ).thenAnswer((_) async => const Right(true));

        await registerUsecase(tParams);

        final captured = verify(
          () => mockAuthRepository.register(captureAny()),
        ).captured;

        final capturedEntity = captured.first as AuthEntity;
        expect(capturedEntity.fullName, equals('John Doe'));
        expect(capturedEntity.email, equals('johndoe@email.com'));
        expect(capturedEntity.username, equals('johndoe'));
        expect(capturedEntity.password, equals('password123'));
        expect(capturedEntity.confirmPassword, equals('password123'));
      },
    );
  });
}
