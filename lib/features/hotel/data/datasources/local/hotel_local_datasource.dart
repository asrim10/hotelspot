import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/hive/hive_service.dart';
import 'package:hotelspot/features/hotel/data/hotel_datasource.dart';
import 'package:hotelspot/features/hotel/data/models/hotel_hive_model.dart';

final hotelLocalDatasourceProvider = Provider<IHotelLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HotelLocalDatasource(hiveService: hiveService);
});

class HotelLocalDatasource implements IHotelLocalDatasource {
  final HiveService _hiveService;

  HotelLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> cacheHotels(List<HotelHiveModel> hotels) async {
    try {
      await _hiveService.clearAllHotels();
      for (final hotel in hotels) {
        await _hiveService.saveHotel(hotel);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<HotelHiveModel>> getAllHotels() async {
    try {
      return await _hiveService.getAllHotels();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<HotelHiveModel?> getHotelById(String hotelId) async {
    try {
      return _hiveService.getHotelById(hotelId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveHotel(HotelHiveModel hotel) async {
    try {
      await _hiveService.saveHotel(hotel);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteHotel(String hotelId) async {
    try {
      return await _hiveService.deleteHotel(hotelId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearAllHotels() async {
    try {
      await _hiveService.clearAllHotels();
      return true;
    } catch (e) {
      return false;
    }
  }
}
