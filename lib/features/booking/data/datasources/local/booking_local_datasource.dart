import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/hive/hive_service.dart';
import 'package:hotelspot/features/booking/data/datasources/booking_datasource.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';

final bookingLocalDatasourceProvider = Provider<BookingLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BookingLocalDatasource(hiveService: hiveService);
});

class BookingLocalDatasource implements IBookingLocalDataSource {
  final HiveService _hiveService;

  BookingLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<BookingHiveModel> createBooking(BookingHiveModel booking) async {
    try {
      final createdBooking = await _hiveService.createBooking(booking);
      return createdBooking;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingHiveModel>> getMyBookings(String userId) async {
    try {
      final bookings = await _hiveService.getMyBookings(userId);
      return bookings;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingHiveModel>> getAllBookings() async {
    try {
      final bookings = await _hiveService.getAllBookings();
      return bookings;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingHiveModel?> getBookingById(String bookingId) async {
    try {
      final booking = _hiveService.getBookingById(bookingId);
      return Future.value(booking);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<BookingHiveModel> updateBooking(BookingHiveModel booking) async {
    try {
      final updatedBooking = await _hiveService.updateBooking(booking);
      return updatedBooking;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingHiveModel?> cancelBooking(String bookingId) async {
    try {
      final cancelledBooking = await _hiveService.cancelBooking(bookingId);
      return cancelledBooking;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<BookingHiveModel?> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    try {
      final updatedBooking = await _hiveService.updatePaymentStatus(
        bookingId,
        paymentStatus,
      );
      return updatedBooking;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<BookingHiveModel?> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    try {
      final updatedBooking = await _hiveService.updatePaymentMethod(
        bookingId,
        paymentMethod,
      );
      return updatedBooking;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<BookingHiveModel?> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final updatedBooking = await _hiveService.updateBookingStatus(
        bookingId,
        status,
      );
      return updatedBooking;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> deleteBooking(String bookingId) async {
    try {
      final success = await _hiveService.deleteBooking(bookingId);
      return success;
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<List<BookingHiveModel>> getBookingsByHotelId(String hotelId) async {
    try {
      final bookings = await _hiveService.getBookingsByHotelId(hotelId);
      return bookings;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingHiveModel>> getBookingsByStatus(
    String userId,
    String status,
  ) async {
    try {
      final bookings = await _hiveService.getBookingsByStatus(userId, status);
      return bookings;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> bookingExists(String bookingId) async {
    try {
      final exists = _hiveService.bookingExists(bookingId);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<void> clearAllBookings() async {
    try {
      await _hiveService.clearAllBookings();
    } catch (e) {
      rethrow;
    }
  }
}
