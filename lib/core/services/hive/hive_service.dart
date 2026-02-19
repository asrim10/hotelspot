import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/auth/data/models/auth_hive_model.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationCacheDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";
    Hive.init(path);
    _registerAdapter();
    await _openBoxes();
  }

  // Register all adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.bookingId)) {
      Hive.registerAdapter(BookingHiveModelAdapter());
    }
  }

  // Open all boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<BookingHiveModel>(HiveTableConstant.bookingTable);
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // =============== Auth CRUD Operations ====================

  // Get auth box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Register
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // Login
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Logout
  Future<void> logoutUser() async {}

  // Get current User
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  // Is Email Exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // =============== Booking CRUD Operations ====================

  // Get booking box
  Box<BookingHiveModel> get _bookingBox =>
      Hive.box<BookingHiveModel>(HiveTableConstant.bookingTable);

  // Create Booking
  Future<BookingHiveModel> createBooking(BookingHiveModel booking) async {
    await _bookingBox.put(booking.bookingId, booking);
    return booking;
  }

  // Get My Bookings (by userId)
  Future<List<BookingHiveModel>> getMyBookings(String userId) async {
    final bookings = _bookingBox.values
        .where((booking) => booking.userId == userId)
        .toList();
    // Sort by creation date (newest first)
    bookings.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return bookings;
  }

  // Get All Bookings
  Future<List<BookingHiveModel>> getAllBookings() async {
    return _bookingBox.values.toList();
  }

  // Get Booking by ID
  BookingHiveModel? getBookingById(String bookingId) {
    return _bookingBox.get(bookingId);
  }

  // Update Booking
  Future<BookingHiveModel> updateBooking(BookingHiveModel booking) async {
    final updatedBooking = booking.copyWith(updatedAt: DateTime.now());
    await _bookingBox.put(updatedBooking.bookingId, updatedBooking);
    return updatedBooking;
  }

  // Cancel Booking
  Future<BookingHiveModel?> cancelBooking(String bookingId) async {
    final booking = _bookingBox.get(bookingId);
    if (booking != null) {
      final cancelledBooking = booking.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(bookingId, cancelledBooking);
      return cancelledBooking;
    }
    return null;
  }

  // Update Payment Status
  Future<BookingHiveModel?> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    final booking = _bookingBox.get(bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(bookingId, updatedBooking);
      return updatedBooking;
    }
    return null;
  }

  // Update Payment Method
  Future<BookingHiveModel?> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    final booking = _bookingBox.get(bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        paymentMethod: paymentMethod,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(bookingId, updatedBooking);
      return updatedBooking;
    }
    return null;
  }

  // Update Booking Status
  Future<BookingHiveModel?> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final booking = _bookingBox.get(bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(bookingId, updatedBooking);
      return updatedBooking;
    }
    return null;
  }

  // Delete Booking
  Future<bool> deleteBooking(String bookingId) async {
    if (_bookingBox.containsKey(bookingId)) {
      await _bookingBox.delete(bookingId);
      return true;
    }
    return false;
  }

  // Get Bookings by Hotel ID
  Future<List<BookingHiveModel>> getBookingsByHotelId(String hotelId) async {
    final bookings = _bookingBox.values
        .where((booking) => booking.hotelId == hotelId)
        .toList();
    return bookings;
  }

  // Get Bookings by Status
  Future<List<BookingHiveModel>> getBookingsByStatus(
    String userId,
    String status,
  ) async {
    final bookings = _bookingBox.values
        .where(
          (booking) => booking.userId == userId && booking.status == status,
        )
        .toList();
    return bookings;
  }

  // Check if booking exists
  bool bookingExists(String bookingId) {
    return _bookingBox.containsKey(bookingId);
  }

  // Clear all bookings (for testing/debugging)
  Future<void> clearAllBookings() async {
    await _bookingBox.clear();
  }
}
