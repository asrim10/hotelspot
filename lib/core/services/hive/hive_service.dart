import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/auth/data/models/auth_hive_model.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_hive_model.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_hive_model.dart';
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
    // Clean up any corrupted string-keyed booking entries from old bug
    await _cleanCorruptedBookingKeys();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.hotelId)) {
      Hive.registerAdapter(HotelHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.bookingId)) {
      Hive.registerAdapter(BookingHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.favouriteId)) {
      Hive.registerAdapter(FavouriteHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<BookingHiveModel>(HiveTableConstant.bookingTable);
    await Hive.openBox<FavouriteHiveModel>(HiveTableConstant.favouriteTable);
    await Hive.openBox<HotelHiveModel>(HiveTableConstant.hotelTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ======================= Auth CRUD ===============================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) return users.first;
    return null;
  }

  Future<void> logoutUser() async {}

  AuthHiveModel? getCurrentUser(String authId) => _authBox.get(authId);

  bool isEmailExists(String email) =>
      _authBox.values.any((user) => user.email == email);

  // ======================= Booking CRUD ===============================

  Box<BookingHiveModel> get _bookingBox =>
      Hive.box<BookingHiveModel>(HiveTableConstant.bookingTable);

  // Deletes any entries that were stored with a string key (old bug remnants)
  Future<void> _cleanCorruptedBookingKeys() async {
    final badKeys = _bookingBox.keys.where((k) => k is! int).toList();
    if (badKeys.isNotEmpty) {
      await _bookingBox.deleteAll(badKeys);
    }
  }

  int? _getHiveKey(String bookingId) {
    for (final key in _bookingBox.keys) {
      if (key is! int) continue; // skip any corrupted non-int key
      final entry = _bookingBox.get(key);
      if (entry != null && entry.bookingId == bookingId) {
        return key;
      }
    }
    return null;
  }

  BookingHiveModel? _findByBookingId(String bookingId) {
    for (final key in _bookingBox.keys) {
      if (key is! int) continue;
      final entry = _bookingBox.get(key);
      if (entry != null && entry.bookingId == bookingId) {
        return entry;
      }
    }
    return null;
  }

  // Create Booking
  Future<BookingHiveModel> createBooking(BookingHiveModel booking) async {
    final existingKey = _getHiveKey(booking.bookingId);
    if (existingKey != null) {
      await _bookingBox.put(existingKey, booking);
    } else {
      await _bookingBox.add(booking);
    }
    return booking;
  }

  // Get My Bookings by userId
  Future<List<BookingHiveModel>> getMyBookings(String userId) async {
    final bookings = _bookingBox.values
        .where((b) => b.userId == userId)
        .toList();
    bookings.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return bookings;
  }

  // Get All Bookings
  Future<List<BookingHiveModel>> getAllBookings() async {
    return _bookingBox.values.toList();
  }

  // Get Booking by bookingId field value
  BookingHiveModel? getBookingById(String bookingId) {
    return _findByBookingId(bookingId);
  }

  // Update Booking
  Future<BookingHiveModel> updateBooking(BookingHiveModel booking) async {
    final updated = booking.copyWith(updatedAt: DateTime.now());
    final key = _getHiveKey(booking.bookingId);
    if (key != null) {
      await _bookingBox.put(key, updated);
    } else {
      await _bookingBox.add(updated);
    }
    return updated;
  }

  // Cancel Booking
  Future<BookingHiveModel?> cancelBooking(String bookingId) async {
    final key = _getHiveKey(bookingId);
    final booking = _findByBookingId(bookingId);
    if (key != null && booking != null) {
      final cancelled = booking.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(key, cancelled);
      return cancelled;
    }
    // Not cached locally — API already cancelled it, that is fine
    return null;
  }

  // Update Payment Status
  Future<BookingHiveModel?> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    final key = _getHiveKey(bookingId);
    final booking = _findByBookingId(bookingId);
    if (key != null && booking != null) {
      final updated = booking.copyWith(
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(key, updated);
      return updated;
    }
    return null;
  }

  // Update Payment Method
  Future<BookingHiveModel?> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    final key = _getHiveKey(bookingId);
    final booking = _findByBookingId(bookingId);
    if (key != null && booking != null) {
      final updated = booking.copyWith(
        paymentMethod: paymentMethod,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(key, updated);
      return updated;
    }
    return null;
  }

  // Update Booking Status
  Future<BookingHiveModel?> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final key = _getHiveKey(bookingId);
    final booking = _findByBookingId(bookingId);
    if (key != null && booking != null) {
      final updated = booking.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _bookingBox.put(key, updated);
      return updated;
    }
    return null;
  }

  // Delete Booking
  Future<bool> deleteBooking(String bookingId) async {
    final key = _getHiveKey(bookingId);
    if (key != null) {
      await _bookingBox.delete(key);
      return true;
    }
    return false;
  }

  // Get Bookings by Hotel ID
  Future<List<BookingHiveModel>> getBookingsByHotelId(String hotelId) async {
    return _bookingBox.values.where((b) => b.hotelId == hotelId).toList();
  }

  // Get Bookings by Status
  Future<List<BookingHiveModel>> getBookingsByStatus(
    String userId,
    String status,
  ) async {
    return _bookingBox.values
        .where((b) => b.userId == userId && b.status == status)
        .toList();
  }

  // Booking Exists
  bool bookingExists(String bookingId) {
    return _findByBookingId(bookingId) != null;
  }

  // Clear All Bookings
  Future<void> clearAllBookings() async {
    await _bookingBox.clear();
  }

  // ======================= Favourite CRUD ===============================

  Box<FavouriteHiveModel> get _favouriteBox =>
      Hive.box<FavouriteHiveModel>(HiveTableConstant.favouriteTable);

  Future<FavouriteHiveModel> addToFavourites(
    FavouriteHiveModel favourite,
  ) async {
    await _favouriteBox.put(favourite.favouriteId, favourite);
    return favourite;
  }

  Future<List<FavouriteHiveModel>> getMyFavourites(String userId) async {
    final favourites = _favouriteBox.values
        .where((fav) => fav.userId == userId)
        .toList();
    favourites.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return favourites;
  }

  Future<bool> removeFromFavourites(String favouriteId) async {
    if (_favouriteBox.containsKey(favouriteId)) {
      await _favouriteBox.delete(favouriteId);
      return true;
    }
    return false;
  }

  Future<bool> removeByHotelId(String userId, String hotelId) async {
    try {
      final fav = _favouriteBox.values.firstWhere(
        (fav) => fav.userId == userId && fav.hotelId == hotelId,
      );
      await _favouriteBox.delete(fav.favouriteId);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isHotelFavourited(String userId, String hotelId) {
    return _favouriteBox.values.any(
      (fav) => fav.userId == userId && fav.hotelId == hotelId,
    );
  }

  // ======================= Hotel CRUD ===============================

  Box<HotelHiveModel> get _hotelBox =>
      Hive.box<HotelHiveModel>(HiveTableConstant.hotelTable);

  /// Cache all hotels (bulk replace — called after a successful API fetch)
  Future<void> cacheHotels(List<HotelHiveModel> hotels) async {
    await _hotelBox.clear();
    final map = {for (final h in hotels) h.hotelId: h};
    await _hotelBox.putAll(map);
  }

  Future<List<HotelHiveModel>> getAllHotels() async {
    return _hotelBox.values.toList();
  }

  HotelHiveModel? getHotelById(String hotelId) {
    return _hotelBox.get(hotelId);
  }

  Future<HotelHiveModel> saveHotel(HotelHiveModel hotel) async {
    await _hotelBox.put(hotel.hotelId, hotel);
    return hotel;
  }

  Future<bool> deleteHotel(String hotelId) async {
    if (_hotelBox.containsKey(hotelId)) {
      await _hotelBox.delete(hotelId);
      return true;
    }
    return false;
  }

  bool hotelExists(String hotelId) => _hotelBox.containsKey(hotelId);

  Future<void> clearAllHotels() async => _hotelBox.clear();
}
