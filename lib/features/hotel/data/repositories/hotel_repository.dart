import 'dart:io';

abstract interface class IHotelRepository {
  Future<List<Map<String, dynamic>>> getAllHotels();
  Future<Map<String, dynamic>> getHotelById(String hotelId);
  Future<void> createHotel(Map<String, dynamic> hotelData);
  Future<void> updateHotel(String hotelId, Map<String, dynamic> hotelData);
  Future<void> deleteHotel(String hotelId);
  Future<String> uploadImage(File image);
  Future<String> uploadVideo(File video);
}
