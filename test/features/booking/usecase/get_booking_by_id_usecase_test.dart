import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_booking_by_id_usecase.dart';

// Mock
class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late GetBookingByIdUsecase getBookingByIdUsecase;
  late MockBookingRepository mockBookingRepository;
  late GetBookingByIdUsecaseParams tParams;
  late BookingEntity tBooking;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    getBookingByIdUsecase = GetBookingByIdUsecase(
      bookingRepository: mockBookingRepository,
    );
    tParams = const GetBookingByIdUsecaseParams(bookingId: 'booking-001');
    tBooking = BookingEntity(
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
  });

  group('GetBookingByIdUsecase', () {
    // Returns booking on success
    test('should return BookingEntity when found successfully', () async {
      when(
        () => mockBookingRepository.getBookingById(any()),
      ).thenAnswer((_) async => Right(tBooking));

      final result = await getBookingByIdUsecase(tParams);

      expect(result, Right<Failure, BookingEntity>(tBooking));
      verify(
        () => mockBookingRepository.getBookingById('booking-001'),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Booking not found');
      when(
        () => mockBookingRepository.getBookingById(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await getBookingByIdUsecase(tParams);

      expect(result, const Left<Failure, BookingEntity>(tFailure));
      verify(
        () => mockBookingRepository.getBookingById('booking-001'),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    //  Passes correct bookingId to repository
    test(
      'should call repository with the correct bookingId from params',
      () async {
        when(
          () => mockBookingRepository.getBookingById(any()),
        ).thenAnswer((_) async => Right(tBooking));

        await getBookingByIdUsecase(tParams);

        final captured = verify(
          () => mockBookingRepository.getBookingById(captureAny()),
        ).captured;

        expect(captured.first, equals('booking-001'));
      },
    );
  });
}
