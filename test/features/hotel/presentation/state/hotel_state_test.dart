import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

void main() {
  group('HotelState Unit Tests', () {
    test('initial state should have default values', () {
      final state = HotelState();

      expect(state.status, HotelStatus.initial);
      expect(state.hotels, isEmpty);
      expect(state.errorMessage, null);
      expect(state.selectedHotel, null);
    });

    test('copyWith should update status to loading', () {
      final state = HotelState();

      final newState = state.copyWith(status: HotelStatus.loading);

      expect(newState.status, HotelStatus.loading);
      expect(newState.hotels, state.hotels);
    });

    test('copyWith should update hotels list', () {
      final hotels = [
        HotelEntity(
          hotelId: '1',
          hotelName: 'Test Hotel',
          price: 1000,
          availableRooms: 5,
          rating: 4.5,
          address: '123 Test St',
          country: 'Testland',
          city: 'Testville',
          imageUrl: 'http://example.com/image.jpg',
        ),
      ];

      final state = HotelState();

      final newState = state.copyWith(
        status: HotelStatus.loaded,
        hotels: hotels,
      );

      expect(newState.status, HotelStatus.loaded);
      expect(newState.hotels.length, 1);
      expect(newState.hotels.first.hotelName, 'Test Hotel');
    });

    test('copyWith should set error message', () {
      final state = HotelState();

      final newState = state.copyWith(
        status: HotelStatus.error,
        errorMessage: 'Failed to load hotels',
      );

      expect(newState.status, HotelStatus.error);
      expect(newState.errorMessage, 'Failed to load hotels');
    });

    test('props should consider two identical states equal', () {
      final state1 = HotelState(status: HotelStatus.loaded);
      final state2 = HotelState(status: HotelStatus.loaded);

      expect(state1, equals(state2));
    });
  });
}
