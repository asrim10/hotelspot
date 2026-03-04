import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "192.168.1.66";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:3000/api/v1';
    }
    // if android
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String updateUser = '/auth/users';
  static const String deleteUser = '/auth/users';
  static const String getProfile = '/auth/whoami';
  static const String updateProfile = '/auth/update-profile';

  // Hotel endpoints
  static const String hotels = '/hotels';
  static String hotelById(String id) => '/hotels/$id';
  static String searchHotels(String searchTerm) => '/hotels/search/$searchTerm';
  static String availableHotels({int? minRooms}) =>
      minRooms != null ? '/hotels/available/$minRooms' : '/hotels/available';
  static String createHotel() => '/hotels';
  static String updateHotel(String id) => '/hotels/$id';
  static String updateHotelImage(String id) => '/hotels/$id/image';
  static String updateAvailableRooms(String id) => '/hotels/$id/rooms';
  static String deleteHotel(String id) => '/hotels/$id';
  static const String uploadImage = '/hotels/upload-photo';
  static const String uploadVideo = '/hotels/upload-video';

  //Booking endpoints
  static const String bookings = '/bookings';
  static String createBooking() => '/bookings';
  static const String myBookings = '/bookings/me';
  static String bookingById(String id) => '/bookings/$id';
  static String updateBooking(String id) => '/bookings/$id';
  static String deleteBooking(String id) => '/bookings/$id';

  //fav endpoints
  static const String favourites = '/favourites';
  static String addFavourite() => '/favourites';
  static const String myFavourites = '/favourites/me';
  static String favouriteById(String id) => '/favourites/$id';
  static String removeFavourite(String id) => '/favourites/$id';

  //payment endpoints
  static const String payments = '/payment';
  static const String initiateKhaltiPayment = '/payment/khalti/initiate';
  static const String verifyKhaltiPayment = '/payment/khalti/verify';

  // Review endpoints
  static const String reviews = '/review';
  static String createReview() => '/review';
  static String reviewById(String id) => '/review/$id';
  static String reviewsByHotelId(String hotelId) => '/review/hotel/$hotelId';
  static const String myReviews = '/review/me';
  static String updateReview(String id) => '/review/$id';
  static String deleteReview(String id) => '/review/$id';
}
