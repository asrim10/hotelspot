import 'package:hotelspot/features/booking/data/models/booking_api_model.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';

abstract interface class IBookingLocalDataSource {
  Future<BookingHiveModel> createBooking(BookingHiveModel booking);
  Future<List<BookingHiveModel>> getMyBookings(String userId);
  Future<List<BookingHiveModel>> getAllBookings();
  Future<BookingHiveModel?> getBookingById(String bookingId);
  Future<BookingHiveModel> updateBooking(BookingHiveModel booking);
  Future<BookingHiveModel?> cancelBooking(String bookingId);
  Future<BookingHiveModel?> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  );
  Future<BookingHiveModel?> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  );
  Future<BookingHiveModel?> updateBookingStatus(
    String bookingId,
    String status,
  );
  Future<bool> deleteBooking(String bookingId);
  Future<List<BookingHiveModel>> getBookingsByHotelId(String hotelId);
  Future<List<BookingHiveModel>> getBookingsByStatus(
    String userId,
    String status,
  );
  Future<bool> bookingExists(String bookingId);
  Future<void> clearAllBookings();
}

abstract interface class IBookingRemoteDataSource {
  Future<BookingApiModel> createBooking(BookingApiModel booking);
  Future<List<BookingApiModel>> getMyBookings();
  Future<BookingApiModel> getBookingById(String bookingId);
  Future<bool> cancelBooking(String bookingId, String reason);
  Future<BookingApiModel> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  );
  Future<BookingApiModel> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  );
  Future<BookingApiModel> updateBookingStatus(String bookingId, String status);
  Future<bool> deleteBooking(String bookingId);
}
