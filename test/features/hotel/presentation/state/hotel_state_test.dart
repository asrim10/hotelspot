import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

void main() {
  late List<HotelEntity> mockHotels;

  setUp(() {
    mockHotels = [
      HotelEntity(
        hotelId: '1',
        hotelName: 'Test Hotel',
        price: 1000,
        availableRooms: 5,
        rating: 4.5,
        address: '123 Test St',
        country: 'Testland',
        city: 'Testville',
        imageUrl: '/uploads/images/test.jpg',
      ),
      HotelEntity(
        hotelId: '2',
        hotelName: 'Second Hotel',
        price: 2000,
        availableRooms: 10,
        rating: 3.5,
        address: '456 Test Ave',
        country: 'Testland',
        city: 'Testcity',
        imageUrl: '/uploads/images/test2.jpg',
      ),
    ];
  });

  group('HotelState - Initial State', () {
    test('initial state should have default values', () {
      final state = HotelState();

      expect(state.status, HotelStatus.initial);
      expect(state.hotels, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.selectedHotel, isNull);
      expect(state.uploadImageName, isNull);
    });
  });

  group('HotelState - Status Transitions', () {
    test('copyWith should update status to loading', () {
      final state = HotelState();
      final newState = state.copyWith(status: HotelStatus.loading);

      expect(newState.status, HotelStatus.loading);
      // Other fields should remain unchanged
      expect(newState.hotels, isEmpty);
      expect(newState.errorMessage, isNull);
    });

    test('copyWith should update status to loaded', () {
      final state = HotelState();
      final newState = state.copyWith(
        status: HotelStatus.loaded,
        hotels: mockHotels,
      );

      expect(newState.status, HotelStatus.loaded);
      expect(newState.hotels.length, 2);
    });

    test('copyWith should update status to created', () {
      final state = HotelState();
      final newState = state.copyWith(status: HotelStatus.created);

      expect(newState.status, HotelStatus.created);
    });

    test('copyWith should update status to error', () {
      final state = HotelState();
      final newState = state.copyWith(
        status: HotelStatus.error,
        errorMessage: 'Failed to load hotels',
      );

      expect(newState.status, HotelStatus.error);
      expect(newState.errorMessage, 'Failed to load hotels');
    });
  });

  group('HotelState - Hotels List', () {
    test('copyWith should update hotels list', () {
      final state = HotelState();
      final newState = state.copyWith(
        status: HotelStatus.loaded,
        hotels: mockHotels,
      );

      expect(newState.hotels.length, 2);
      expect(newState.hotels[0].hotelName, 'Test Hotel');
      expect(newState.hotels[1].hotelName, 'Second Hotel');
    });

    test('copyWith should preserve hotels when updating other fields', () {
      final state = HotelState(status: HotelStatus.loaded, hotels: mockHotels);

      // Update only status, hotels should remain
      final newState = state.copyWith(status: HotelStatus.loading);

      expect(newState.hotels.length, 2);
      expect(newState.hotels[0].hotelName, 'Test Hotel');
    });

    test('copyWith should clear hotels when empty list is passed', () {
      final state = HotelState(status: HotelStatus.loaded, hotels: mockHotels);

      final newState = state.copyWith(status: HotelStatus.created, hotels: []);

      expect(newState.hotels, isEmpty);
    });

    test('hotels list should contain correct hotel data', () {
      final state = HotelState(status: HotelStatus.loaded, hotels: mockHotels);

      final hotel = state.hotels.first;

      expect(hotel.hotelId, '1');
      expect(hotel.hotelName, 'Test Hotel');
      expect(hotel.price, 1000);
      expect(hotel.availableRooms, 5);
      expect(hotel.rating, 4.5);
      expect(hotel.address, '123 Test St');
      expect(hotel.country, 'Testland');
      expect(hotel.city, 'Testville');
      expect(hotel.imageUrl, '/uploads/images/test.jpg');
    });
  });

  group('HotelState - Upload Image', () {
    test('copyWith should update uploadImageName', () {
      final state = HotelState();
      final newState = state.copyWith(
        status: HotelStatus.loaded,
        uploadImageName: '/uploads/images/new-image.jpg',
      );

      expect(newState.uploadImageName, '/uploads/images/new-image.jpg');
      expect(newState.status, HotelStatus.loaded);
    });

    test('uploadImageName should be null initially', () {
      final state = HotelState();
      expect(state.uploadImageName, isNull);
    });

    test(
      'copyWith should preserve uploadImageName when updating other fields',
      () {
        final state = HotelState(
          status: HotelStatus.loaded,
          uploadImageName: '/uploads/images/cached.jpg',
        );

        final newState = state.copyWith(status: HotelStatus.loading);

        expect(newState.uploadImageName, '/uploads/images/cached.jpg');
      },
    );
  });

  group('HotelState - Error Handling', () {
    test('error message should be null when status is not error', () {
      final state = HotelState(status: HotelStatus.loaded);
      expect(state.errorMessage, isNull);
    });

    test(
      'copyWith should clear error message when transitioning to loading',
      () {
        final errorState = HotelState(
          status: HotelStatus.error,
          errorMessage: 'Some error',
        );

        final newState = errorState.copyWith(
          status: HotelStatus.loading,
          errorMessage: null,
        );

        expect(newState.status, HotelStatus.loading);
        expect(newState.errorMessage, isNull);
      },
    );

    test(
      'error state should preserve hotels from previous successful load',
      () {
        final state = HotelState(
          status: HotelStatus.loaded,
          hotels: mockHotels,
        );

        // Simulate error on refresh but keep old hotels
        final errorState = state.copyWith(
          status: HotelStatus.error,
          errorMessage: 'Network error',
        );

        expect(errorState.status, HotelStatus.error);
        expect(errorState.errorMessage, 'Network error');
        expect(errorState.hotels.length, 2); // Old hotels still there
      },
    );
  });

  group('HotelState - Equality', () {
    test('two states with same values should be equal', () {
      final state1 = HotelState(status: HotelStatus.loaded, hotels: mockHotels);
      final state2 = HotelState(status: HotelStatus.loaded, hotels: mockHotels);

      expect(state1, equals(state2));
    });

    test('two states with different status should not be equal', () {
      final state1 = HotelState(status: HotelStatus.loading);
      final state2 = HotelState(status: HotelStatus.loaded);

      expect(state1, isNot(equals(state2)));
    });

    test('two states with different hotels should not be equal', () {
      final state1 = HotelState(status: HotelStatus.loaded, hotels: mockHotels);
      final state2 = HotelState(status: HotelStatus.loaded, hotels: []);

      expect(state1, isNot(equals(state2)));
    });

    test('two states with different error messages should not be equal', () {
      final state1 = HotelState(
        status: HotelStatus.error,
        errorMessage: 'Error A',
      );
      final state2 = HotelState(
        status: HotelStatus.error,
        errorMessage: 'Error B',
      );

      expect(state1, isNot(equals(state2)));
    });
  });

  group('HotelState - Selected Hotel', () {
    test('copyWith should update selected hotel', () {
      final state = HotelState();
      final newState = state.copyWith(selectedHotel: mockHotels.first);

      expect(newState.selectedHotel, isNotNull);
      expect(newState.selectedHotel!.hotelName, 'Test Hotel');
    });

    test('selected hotel should be null initially', () {
      final state = HotelState();
      expect(state.selectedHotel, isNull);
    });
  });
}
