import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/delete_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_my_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_booking_status_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_payment_method_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_payment_status_usecase.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';

// Mocks
class MockCreateBookingUsecase extends Mock implements CreateBookingUsecase {}

class MockGetMyBookingsUsecase extends Mock implements GetMyBookingsUsecase {}

class MockGetBookingByIdUsecase extends Mock implements GetBookingByIdUsecase {}

class MockCancelBookingUsecase extends Mock implements CancelBookingUsecase {}

class MockUpdatePaymentStatusUsecase extends Mock
    implements UpdatePaymentStatusUsecase {}

class MockUpdatePaymentMethodUsecase extends Mock
    implements UpdatePaymentMethodUsecase {}

class MockUpdateBookingStatusUsecase extends Mock
    implements UpdateBookingStatusUsecase {}

class MockDeleteBookingUsecase extends Mock implements DeleteBookingUsecase {}

// Fakes
class FakeCreateBookingUsecaseParams extends Fake
    implements CreateBookingUsecaseParams {}

class FakeGetBookingByIdUsecaseParams extends Fake
    implements GetBookingByIdUsecaseParams {}

class FakeCancelBookingUsecaseParams extends Fake
    implements CancelBookingUsecaseParams {}

class FakeUpdatePaymentStatusUsecaseParams extends Fake
    implements UpdatePaymentStatusUsecaseParams {}

class FakeUpdatePaymentMethodUsecaseParams extends Fake
    implements UpdatePaymentMethodUsecaseParams {}

class FakeUpdateBookingStatusUsecaseParams extends Fake
    implements UpdateBookingStatusUsecaseParams {}

class FakeDeleteBookingUsecaseParams extends Fake
    implements DeleteBookingUsecaseParams {}

void main() {
  late MockCreateBookingUsecase mockCreateBookingUsecase;
  late MockGetMyBookingsUsecase mockGetMyBookingsUsecase;
  late MockGetBookingByIdUsecase mockGetBookingByIdUsecase;
  late MockCancelBookingUsecase mockCancelBookingUsecase;
  late MockUpdatePaymentStatusUsecase mockUpdatePaymentStatusUsecase;
  late MockUpdatePaymentMethodUsecase mockUpdatePaymentMethodUsecase;
  late MockUpdateBookingStatusUsecase mockUpdateBookingStatusUsecase;
  late MockDeleteBookingUsecase mockDeleteBookingUsecase;
  late ProviderContainer container;
  late BookingEntity tBooking;
  late List<BookingEntity> tBookings;

  setUpAll(() {
    registerFallbackValue(FakeCreateBookingUsecaseParams());
    registerFallbackValue(FakeGetBookingByIdUsecaseParams());
    registerFallbackValue(FakeCancelBookingUsecaseParams());
    registerFallbackValue(FakeUpdatePaymentStatusUsecaseParams());
    registerFallbackValue(FakeUpdatePaymentMethodUsecaseParams());
    registerFallbackValue(FakeUpdateBookingStatusUsecaseParams());
    registerFallbackValue(FakeDeleteBookingUsecaseParams());
  });

  setUp(() {
    mockCreateBookingUsecase = MockCreateBookingUsecase();
    mockGetMyBookingsUsecase = MockGetMyBookingsUsecase();
    mockGetBookingByIdUsecase = MockGetBookingByIdUsecase();
    mockCancelBookingUsecase = MockCancelBookingUsecase();
    mockUpdatePaymentStatusUsecase = MockUpdatePaymentStatusUsecase();
    mockUpdatePaymentMethodUsecase = MockUpdatePaymentMethodUsecase();
    mockUpdateBookingStatusUsecase = MockUpdateBookingStatusUsecase();
    mockDeleteBookingUsecase = MockDeleteBookingUsecase();

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

    tBookings = [
      tBooking,
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

    container = ProviderContainer(
      overrides: [
        createBookingUsecaseProvider.overrideWithValue(
          mockCreateBookingUsecase,
        ),
        getMyBookingsUsecaseProvider.overrideWithValue(
          mockGetMyBookingsUsecase,
        ),
        getBookingByIdUsecaseProvider.overrideWithValue(
          mockGetBookingByIdUsecase,
        ),
        cancelBookingUsecaseProvider.overrideWithValue(
          mockCancelBookingUsecase,
        ),
        updatePaymentStatusUsecaseProvider.overrideWithValue(
          mockUpdatePaymentStatusUsecase,
        ),
        updatePaymentMethodUsecaseProvider.overrideWithValue(
          mockUpdatePaymentMethodUsecase,
        ),
        updateBookingStatusUsecaseProvider.overrideWithValue(
          mockUpdateBookingStatusUsecase,
        ),
        deleteBookingUsecaseProvider.overrideWithValue(
          mockDeleteBookingUsecase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  BookingViewModel readViewModel() =>
      container.read(bookingViewModelProvider.notifier);

  BookingState readState() => container.read(bookingViewModelProvider);

  group('BookingViewModel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(BookingStatus.initial));
        expect(readState().bookings, isEmpty);
        expect(readState().currentBooking, isNull);
        expect(readState().errorMessage, isNull);
      });
    });

    group('createBooking', () {
      test('should emit creating then created status on success', () async {
        when(
          () => mockCreateBookingUsecase(any()),
        ).thenAnswer((_) async => Right(tBooking));

        await readViewModel().createBooking(tBooking);

        expect(readState().status, equals(BookingStatus.created));
        expect(readState().currentBooking, equals(tBooking));
        expect(readState().bookings, contains(tBooking));
      });

      test('should emit error status when createBooking fails', () async {
        const tFailure = ApiFailure(message: 'Failed to create booking');
        when(
          () => mockCreateBookingUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().createBooking(tBooking);

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to create booking'));
      });
    });

    group('getMyBookings', () {
      test('should emit loading then loaded status on success', () async {
        when(() => mockGetMyBookingsUsecase()).thenAnswer(
          (_) async => Right<Failure, List<BookingEntity>>(tBookings),
        );

        await readViewModel().getMyBookings();

        expect(readState().status, equals(BookingStatus.loaded));
        expect(readState().bookings, equals(tBookings));
      });

      test('should emit error status when getMyBookings fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load bookings');
        when(
          () => mockGetMyBookingsUsecase(),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getMyBookings();

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to load bookings'));
      });
    });

    group('getBookingById', () {
      test(
        'should emit loading then loaded status with currentBooking on success',
        () async {
          when(
            () => mockGetBookingByIdUsecase(any()),
          ).thenAnswer((_) async => Right(tBooking));

          await readViewModel().getBookingById('booking-001');

          expect(readState().status, equals(BookingStatus.loaded));
          expect(readState().currentBooking, equals(tBooking));
        },
      );

      test('should emit error status when getBookingById fails', () async {
        const tFailure = ApiFailure(message: 'Booking not found');
        when(
          () => mockGetBookingByIdUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getBookingById('booking-001');

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Booking not found'));
      });
    });

    group('cancelBooking', () {
      test(
        'should emit cancelling then cancelled and update booking status on success',
        () async {
          when(() => mockGetMyBookingsUsecase()).thenAnswer(
            (_) async => Right<Failure, List<BookingEntity>>(tBookings),
          );
          await readViewModel().getMyBookings();

          when(
            () => mockCancelBookingUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          await readViewModel().cancelBooking('booking-001', 'Change of plans');

          expect(readState().status, equals(BookingStatus.cancelled));
          final cancelledBooking = readState().bookings.firstWhere(
            (b) => b.bookingId == 'booking-001',
          );
          expect(cancelledBooking.status, equals('cancelled'));
        },
      );

      test('should emit error status when cancelBooking fails', () async {
        const tFailure = ApiFailure(message: 'Failed to cancel booking');
        when(
          () => mockCancelBookingUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().cancelBooking('booking-001', 'Change of plans');

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to cancel booking'));
      });

      test('should emit error when cancelBooking returns false', () async {
        when(
          () => mockCancelBookingUsecase(any()),
        ).thenAnswer((_) async => const Right(false));

        await readViewModel().cancelBooking('booking-001', 'Change of plans');

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to cancel booking'));
      });
    });

    group('updatePaymentStatus', () {
      test('should emit updating then updated status on success', () async {
        final updatedBooking = BookingEntity(
          bookingId: 'booking-001',
          userId: 'user-456',
          hotelId: 'hotel-123',
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          checkInDate: '2025-06-01',
          checkOutDate: '2025-06-05',
          totalPrice: 499.99,
          status: 'confirmed',
          paymentStatus: 'paid',
        );
        when(
          () => mockUpdatePaymentStatusUsecase(any()),
        ).thenAnswer((_) async => Right(updatedBooking));

        await readViewModel().updatePaymentStatus('booking-001', 'paid');

        expect(readState().status, equals(BookingStatus.updated));
        expect(readState().currentBooking, equals(updatedBooking));
      });

      test('should emit error status when updatePaymentStatus fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update payment status');
        when(
          () => mockUpdatePaymentStatusUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updatePaymentStatus('booking-001', 'paid');

        expect(readState().status, equals(BookingStatus.error));
        expect(
          readState().errorMessage,
          equals('Failed to update payment status'),
        );
      });
    });

    group('updatePaymentMethod', () {
      test('should emit updating then updated status on success', () async {
        final updatedBooking = BookingEntity(
          bookingId: 'booking-001',
          userId: 'user-456',
          hotelId: 'hotel-123',
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          checkInDate: '2025-06-01',
          checkOutDate: '2025-06-05',
          totalPrice: 499.99,
          status: 'confirmed',
          paymentMethod: 'khalti',
        );
        when(
          () => mockUpdatePaymentMethodUsecase(any()),
        ).thenAnswer((_) async => Right(updatedBooking));

        await readViewModel().updatePaymentMethod('booking-001', 'khalti');

        expect(readState().status, equals(BookingStatus.updated));
        expect(readState().currentBooking, equals(updatedBooking));
      });

      test('should emit error status when updatePaymentMethod fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update payment method');
        when(
          () => mockUpdatePaymentMethodUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updatePaymentMethod('booking-001', 'khalti');

        expect(readState().status, equals(BookingStatus.error));
        expect(
          readState().errorMessage,
          equals('Failed to update payment method'),
        );
      });
    });

    group('updateBookingStatus', () {
      test('should emit updating then updated status on success', () async {
        final updatedBooking = BookingEntity(
          bookingId: 'booking-001',
          userId: 'user-456',
          hotelId: 'hotel-123',
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          checkInDate: '2025-06-01',
          checkOutDate: '2025-06-05',
          totalPrice: 499.99,
          status: 'checked-in',
        );
        when(
          () => mockUpdateBookingStatusUsecase(any()),
        ).thenAnswer((_) async => Right(updatedBooking));

        await readViewModel().updateBookingStatus('booking-001', 'checked-in');

        expect(readState().status, equals(BookingStatus.updated));
        expect(readState().currentBooking, equals(updatedBooking));
      });

      test('should emit error status when updateBookingStatus fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update booking status');
        when(
          () => mockUpdateBookingStatusUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updateBookingStatus('booking-001', 'checked-in');

        expect(readState().status, equals(BookingStatus.error));
        expect(
          readState().errorMessage,
          equals('Failed to update booking status'),
        );
      });
    });

    group('deleteBooking', () {
      test(
        'should emit deleting then deleted and remove booking from list on success',
        () async {
          when(() => mockGetMyBookingsUsecase()).thenAnswer(
            (_) async => Right<Failure, List<BookingEntity>>(tBookings),
          );
          await readViewModel().getMyBookings();

          when(
            () => mockDeleteBookingUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          await readViewModel().deleteBooking('booking-001');

          expect(readState().status, equals(BookingStatus.deleted));
          expect(
            readState().bookings.any((b) => b.bookingId == 'booking-001'),
            isFalse,
          );
        },
      );

      test('should emit error status when deleteBooking fails', () async {
        const tFailure = ApiFailure(message: 'Failed to delete booking');
        when(
          () => mockDeleteBookingUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().deleteBooking('booking-001');

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to delete booking'));
      });

      test('should emit error when deleteBooking returns false', () async {
        when(
          () => mockDeleteBookingUsecase(any()),
        ).thenAnswer((_) async => const Right(false));

        await readViewModel().deleteBooking('booking-001');

        expect(readState().status, equals(BookingStatus.error));
        expect(readState().errorMessage, equals('Failed to delete booking'));
      });
    });

    group('resetState', () {
      test('should reset state back to initial', () async {
        when(() => mockGetMyBookingsUsecase()).thenAnswer(
          (_) async => Right<Failure, List<BookingEntity>>(tBookings),
        );
        await readViewModel().getMyBookings();

        readViewModel().resetState();

        expect(readState().status, equals(BookingStatus.initial));
        expect(readState().bookings, isEmpty);
        expect(readState().currentBooking, isNull);
        expect(readState().errorMessage, isNull);
      });
    });
  });
}
