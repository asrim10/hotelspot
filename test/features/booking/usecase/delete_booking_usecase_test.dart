import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/usecases/delete_booking_usecase.dart';

// Mock
class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late DeleteBookingUsecase deleteBookingUsecase;
  late MockBookingRepository mockBookingRepository;
  late DeleteBookingUsecaseParams tParams;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    deleteBookingUsecase = DeleteBookingUsecase(
      bookingRepository: mockBookingRepository,
    );
    tParams = const DeleteBookingUsecaseParams(bookingId: 'booking-001');
  });

  group('DeleteBookingUsecase', () {
    // Returns true on successful deletion
    test('should return true when booking is deleted successfully', () async {
      when(
        () => mockBookingRepository.deleteBooking(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await deleteBookingUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockBookingRepository.deleteBooking('booking-001'),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to delete booking');
      when(
        () => mockBookingRepository.deleteBooking(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await deleteBookingUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(
        () => mockBookingRepository.deleteBooking('booking-001'),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    //  Passes correct bookingId to repository
    test(
      'should call repository with the correct bookingId from params',
      () async {
        when(
          () => mockBookingRepository.deleteBooking(any()),
        ).thenAnswer((_) async => const Right(true));

        await deleteBookingUsecase(tParams);

        final captured = verify(
          () => mockBookingRepository.deleteBooking(captureAny()),
        ).captured;

        expect(captured.first, equals('booking-001'));
      },
    );
  });
}
