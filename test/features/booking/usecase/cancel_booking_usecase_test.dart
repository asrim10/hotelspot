import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/usecases/cancel_booking_usecase.dart';

// Mock
class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late CancelBookingUsecase cancelBookingUsecase;
  late MockBookingRepository mockBookingRepository;
  late CancelBookingUsecaseParams tParams;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    cancelBookingUsecase = CancelBookingUsecase(
      bookingRepository: mockBookingRepository,
    );
    tParams = const CancelBookingUsecaseParams(
      bookingId: 'booking-001',
      reason: 'Change of plans',
    );
  });

  group('CancelBookingUsecase', () {
    // Returns true on successful cancellation
    test('should return true when booking is cancelled successfully', () async {
      when(
        () => mockBookingRepository.cancelBooking(any(), any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await cancelBookingUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockBookingRepository.cancelBooking(
          'booking-001',
          'Change of plans',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    //  Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to cancel booking');
      when(
        () => mockBookingRepository.cancelBooking(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await cancelBookingUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(
        () => mockBookingRepository.cancelBooking(
          'booking-001',
          'Change of plans',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    // Passes correct bookingId and reason to repository
    test(
      'should call repository with correct bookingId and reason from params',
      () async {
        when(
          () => mockBookingRepository.cancelBooking(any(), any()),
        ).thenAnswer((_) async => const Right(true));

        await cancelBookingUsecase(tParams);

        final captured = verify(
          () => mockBookingRepository.cancelBooking(captureAny(), captureAny()),
        ).captured;

        expect(captured[0], equals('booking-001'));
        expect(captured[1], equals('Change of plans'));
      },
    );
  });
}
