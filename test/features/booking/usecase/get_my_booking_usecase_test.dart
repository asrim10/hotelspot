import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_my_booking_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

// Mock
class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late GetMyBookingsUsecase getMyBookingsUsecase;
  late MockBookingRepository mockBookingRepository;
  late List<BookingEntity> tBookings;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    getMyBookingsUsecase = GetMyBookingsUsecase(
      bookingRepository: mockBookingRepository,
    );

    tBookings = [
      BookingEntity(
        bookingId: 'booking-001',
        userId: 'user-456',
        hotelId: 'hotel-123',
        fullName: 'John Doe',
        email: 'johndoe@email.com',
        checkInDate: '2025-06-01',
        checkOutDate: '2025-06-05',
        totalPrice: 499.99,
        status: 'confirmed',
      ),
      BookingEntity(
        bookingId: 'booking-002',
        userId: 'user-456',
        hotelId: 'hotel-789',
        fullName: 'John Doe',
        email: 'johndoe@email.com',
        checkInDate: '2025-07-10',
        checkOutDate: '2025-07-15',
        totalPrice: 299.99,
        status: 'pending',
      ),
    ];
  });

  group('GetMyBookingsUsecase', () {
    // Returns list of bookings on success
    test('should return list of BookingEntity when successful', () async {
      when(
        () => mockBookingRepository.getMyBookings(),
      ).thenAnswer((_) async => Right<Failure, List<BookingEntity>>(tBookings));

      final result = await getMyBookingsUsecase();

      expect(result, Right<Failure, List<BookingEntity>>(tBookings));
      verify(() => mockBookingRepository.getMyBookings()).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    // Returns empty list when user has no bookings
    test('should return empty list when user has no bookings', () async {
      when(
        () => mockBookingRepository.getMyBookings(),
      ).thenAnswer((_) async => Right<Failure, List<BookingEntity>>([]));

      final result = await getMyBookingsUsecase();

      // fold is used because dartz doesn't deep-compare two separate Right([]) instances
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (bookings) => expect(bookings, isEmpty),
      );
      verify(() => mockBookingRepository.getMyBookings()).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Internal server error');
      when(
        () => mockBookingRepository.getMyBookings(),
      ).thenAnswer((_) async => Left<Failure, List<BookingEntity>>(tFailure));

      final result = await getMyBookingsUsecase();

      expect(result, Left<Failure, List<BookingEntity>>(tFailure));
      verify(() => mockBookingRepository.getMyBookings()).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });
}
