import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hotelspot/core/constants/hive_table_constant.dart';
import 'package:hotelspot/features/auth/data/models/auth_hive_model.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';
import 'package:hotelspot/features/favourites/data/models/favourite_hive_model.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_hive_model.dart';
import 'package:hotelspot/features/reviews/data/models/review_hive_model.dart';
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
    if (!Hive.isAdapterRegistered(HiveTableConstant.reviewId)) {
      Hive.registerAdapter(ReviewHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<BookingHiveModel>(HiveTableConstant.bookingTable);
    await Hive.openBox<FavouriteHiveModel>(HiveTableConstant.favouriteTable);
    await Hive.openBox<HotelHiveModel>(HiveTableConstant.hotelTable);
    await Hive.openBox<ReviewHiveModel>(HiveTableConstant.reviewTable);
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

  Future<void> _cleanCorruptedBookingKeys() async {
    final badKeys = _bookingBox.keys.where((k) => k is! int).toList();
    if (badKeys.isNotEmpty) {
      await _bookingBox.deleteAll(badKeys);
    }
  }

  int? _getHiveKey(String bookingId) {
    for (final key in _bookingBox.keys) {
      if (key is! int) continue;
      final entry = _bookingBox.get(key);
      if (entry != null && entry.bookingId == bookingId) return key;
    }
    return null;
  }

  BookingHiveModel? _findByBookingId(String bookingId) {
    for (final key in _bookingBox.keys) {
      if (key is! int) continue;
      final entry = _bookingBox.get(key);
      if (entry != null && entry.bookingId == bookingId) return entry;
    }
    return null;
  }

  Future<BookingHiveModel> createBooking(BookingHiveModel booking) async {
    final existingKey = _getHiveKey(booking.bookingId);
    if (existingKey != null) {
      await _bookingBox.put(existingKey, booking);
    } else {
      await _bookingBox.add(booking);
    }
    return booking;
  }

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

  Future<List<BookingHiveModel>> getAllBookings() async =>
      _bookingBox.values.toList();

  BookingHiveModel? getBookingById(String bookingId) =>
      _findByBookingId(bookingId);

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
    return null;
  }

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

  Future<bool> deleteBooking(String bookingId) async {
    final key = _getHiveKey(bookingId);
    if (key != null) {
      await _bookingBox.delete(key);
      return true;
    }
    return false;
  }

  Future<List<BookingHiveModel>> getBookingsByHotelId(String hotelId) async =>
      _bookingBox.values.where((b) => b.hotelId == hotelId).toList();

  Future<List<BookingHiveModel>> getBookingsByStatus(
    String userId,
    String status,
  ) async => _bookingBox.values
      .where((b) => b.userId == userId && b.status == status)
      .toList();

  bool bookingExists(String bookingId) => _findByBookingId(bookingId) != null;

  Future<void> clearAllBookings() async => _bookingBox.clear();

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

  bool isHotelFavourited(String userId, String hotelId) => _favouriteBox.values
      .any((fav) => fav.userId == userId && fav.hotelId == hotelId);

  // ======================= Hotel CRUD ===============================

  Box<HotelHiveModel> get _hotelBox =>
      Hive.box<HotelHiveModel>(HiveTableConstant.hotelTable);

  Future<void> cacheHotels(List<HotelHiveModel> hotels) async {
    await _hotelBox.clear();
    final map = {for (final h in hotels) h.hotelId: h};
    await _hotelBox.putAll(map);
  }

  Future<List<HotelHiveModel>> getAllHotels() async =>
      _hotelBox.values.toList();

  HotelHiveModel? getHotelById(String hotelId) => _hotelBox.get(hotelId);

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

  // ======================= Review CRUD ===============================

  Box<ReviewHiveModel> get _reviewBox =>
      Hive.box<ReviewHiveModel>(HiveTableConstant.reviewTable);

  Future<void> cacheReviewsByHotelId(
    String hotelId,
    List<ReviewHiveModel> reviews,
  ) async {
    final oldKeys = _reviewBox.keys
        .where((k) => _reviewBox.get(k)?.hotelId == hotelId)
        .toList();
    await _reviewBox.deleteAll(oldKeys);

    final map = {for (final r in reviews) r.reviewId: r};
    await _reviewBox.putAll(map);
  }

  Future<List<ReviewHiveModel>> getReviewsByHotelId(String hotelId) async {
    final reviews = _reviewBox.values
        .where((r) => r.hotelId == hotelId)
        .toList();
    reviews.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return reviews;
  }

  Future<List<ReviewHiveModel>> getMyReviews(String userId) async {
    final reviews = _reviewBox.values.where((r) => r.userId == userId).toList();
    reviews.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return reviews;
  }

  ReviewHiveModel? getReviewById(String reviewId) => _reviewBox.get(reviewId);

  Future<ReviewHiveModel> saveReview(ReviewHiveModel review) async {
    await _reviewBox.put(review.reviewId, review);
    return review;
  }

  Future<ReviewHiveModel> updateReview(ReviewHiveModel review) async {
    final updated = ReviewHiveModel(
      reviewId: review.reviewId,
      userId: review.userId,
      hotelId: review.hotelId,
      fullName: review.fullName,
      email: review.email,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      updatedAt: DateTime.now(),
    );
    await _reviewBox.put(updated.reviewId, updated);
    return updated;
  }

  Future<bool> deleteReview(String reviewId) async {
    if (_reviewBox.containsKey(reviewId)) {
      await _reviewBox.delete(reviewId);
      return true;
    }
    return false;
  }

  bool reviewExists(String reviewId) => _reviewBox.containsKey(reviewId);

  Future<void> clearReviewsByHotelId(String hotelId) async {
    final keys = _reviewBox.keys
        .where((k) => _reviewBox.get(k)?.hotelId == hotelId)
        .toList();
    await _reviewBox.deleteAll(keys);
  }

  Future<void> clearAllReviews() async => _reviewBox.clear();
}
