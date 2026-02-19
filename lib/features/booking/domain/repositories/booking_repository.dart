import 'package:dartz/dartz.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';

abstract interface class IBookingRepository {
  // Create Booking
  Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking);

  // Get My Bookings
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();

  // Get Booking by ID
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);

  // Cancel Booking
  Future<Either<Failure, bool>> cancelBooking(String bookingId, String reason);

  // Update Payment Status (pending / paid / failed)
  Future<Either<Failure, BookingEntity>> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  );

  // Update Payment Method (cash / card / online)
  Future<Either<Failure, BookingEntity>> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  );

  // Update Booking Status (confirmed / cancelled / checked_in / checked_out)
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status,
  );

  // Delete Booking
  Future<Either<Failure, bool>> deleteBooking(String bookingId);
}
