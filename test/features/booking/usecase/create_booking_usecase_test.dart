import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/usecases/create_booking_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

class FakeBookingEntity extends Fake implements BookingEntity {}

void main() {
  late CreateBookingUsecase createBookingUsecase;
  late MockBookingRepository mockBookingRepository;

  // Sample booking entity used across tests
  final tBooking = BookingEntity(
    bookingId: 'booking-001',
    userId: 'user-456',
    hotelId: 'hotel-123',
    fullName: 'John Doe',
    email: 'johndoe@email.com',
    checkInDate: '2025-06-01',
    checkOutDate: '2025-06-05',
    totalPrice: 499.99,
    status: 'confirmed',
  );

  final tParams = CreateBookingUsecaseParams(booking: tBooking);

  setUpAll(() {
    // Required by mocktail when passing custom objects as arguments
    registerFallbackValue(FakeBookingEntity());
  });

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    createBookingUsecase = CreateBookingUsecase(
      bookingRepository: mockBookingRepository,
    );
  });

  group('CreateBookingUsecase', () {
    test(
      'should return BookingEntity when repository creates booking successfully',
      () async {
        // Arrange
        when(
          () => mockBookingRepository.createBooking(any()),
        ).thenAnswer((_) async => Right(tBooking));

        // Act
        final result = await createBookingUsecase(tParams);

        // Assert
        expect(result, Right(tBooking));
        verify(() => mockBookingRepository.createBooking(tBooking)).called(1);
        verifyNoMoreInteractions(mockBookingRepository);
      },
    );

    test(
      'should return ServerFailure when repository fails due to a server error',
      () async {
        // Arrange
        const tFailure = ApiFailure(message: 'Internal server error');
        when(
          () => mockBookingRepository.createBooking(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await createBookingUsecase(tParams);

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockBookingRepository.createBooking(tBooking)).called(1);
        verifyNoMoreInteractions(mockBookingRepository);
      },
    );

    test(
      'should call repository with the exact BookingEntity provided in params',
      () async {
        // Arrange
        when(
          () => mockBookingRepository.createBooking(any()),
        ).thenAnswer((_) async => Right(tBooking));

        // Act
        await createBookingUsecase(tParams);

        // Assert — verifies the usecase correctly delegates to the repository
        // with the exact entity from params (not a modified/wrong one)
        final captured = verify(
          () => mockBookingRepository.createBooking(captureAny()),
        ).captured;

        expect(captured.first, equals(tBooking));
      },
    );
  });
}
