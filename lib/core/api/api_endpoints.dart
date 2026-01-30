import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.1";

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

  //hotel endpoints

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
  static const String uploadImage = '/upload-image';
  static const String uploadVideo = '/upload-video';
}
