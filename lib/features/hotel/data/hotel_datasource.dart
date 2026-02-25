import 'dart:io';

import 'package:hotelspot/features/hotel/data/models/hotel_api_model.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_hive_model.dart';

abstract interface class IHotelLocalDatasource {
  Future<bool> cacheHotels(List<HotelHiveModel> hotels);
  Future<List<HotelHiveModel>> getAllHotels();
  Future<HotelHiveModel?> getHotelById(String hotelId);
  Future<bool> saveHotel(HotelHiveModel hotel);
  Future<bool> deleteHotel(String hotelId);
  Future<bool> clearAllHotels();
}

abstract interface class IHotelRemoteDatasource {
  Future<List<HotelApiModel>> getAllHotels();
  Future<HotelApiModel> getHotelById(String hotelId);
  Future<bool> createHotel(Map<String, dynamic> hotelData);
  Future<bool> updateHotel(String hotelId, Map<String, dynamic> hotelData);
  Future<bool> deleteHotel(String hotelId);
  Future<String> uploadImage(File image);
  Future<String> uploadVideo(File video);
}
