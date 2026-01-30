import 'dart:io';

abstract class IHotelRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllHotels();
  Future<Map<String, dynamic>> getHotelById(String hotelId);
  Future<bool> createHotel(Map<String, dynamic> hotelData);
  Future<bool> updateHotel(String hotelId, Map<String, dynamic> hotelData);
  Future<bool> deleteHotel(String hotelId);
  Future<String> uploadImage(File image);
  Future<String> uploadVideo(File video);
}
