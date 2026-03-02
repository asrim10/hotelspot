import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/usecases/create_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/get_all_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/get_hotel_by_id_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/update_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/delete_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/upload_image_usecase.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

// Mocks
class MockCreateHotelUsecase extends Mock implements CreateHotelUsecase {}

class MockGetAllHotelsUsecase extends Mock implements GetAllHotelsUsecase {}

class MockGetHotelByIdUsecase extends Mock implements GetHotelByIdUsecase {}

class MockUpdateHotelUsecase extends Mock implements UpdateHotelUsecase {}

class MockDeleteHotelUsecase extends Mock implements DeleteHotelUsecase {}

class MockUploadImageUsecase extends Mock implements UploadImageUsecase {}

// Fakes
class FakeCreateHotelParams extends Fake implements CreateHotelParams {}

class FakeGetHotelByIdParams extends Fake implements GetHotelByIdParams {}

class FakeUpdateHotelParams extends Fake implements UpdateHotelParams {}

class FakeDeleteHotelParams extends Fake implements DeleteHotelParams {}

class FakeUploadImageParams extends Fake implements UploadImageParams {}

class FakeFile extends Fake implements File {}

void main() {
  late MockCreateHotelUsecase mockCreateHotelUsecase;
  late MockGetAllHotelsUsecase mockGetAllHotelsUsecase;
  late MockGetHotelByIdUsecase mockGetHotelByIdUsecase;
  late MockUpdateHotelUsecase mockUpdateHotelUsecase;
  late MockDeleteHotelUsecase mockDeleteHotelUsecase;
  late MockUploadImageUsecase mockUploadImageUsecase;
  late ProviderContainer container;
  late HotelEntity tHotel;
  late List<HotelEntity> tHotels;

  setUpAll(() {
    registerFallbackValue(FakeCreateHotelParams());
    registerFallbackValue(FakeGetHotelByIdParams());
    registerFallbackValue(FakeUpdateHotelParams());
    registerFallbackValue(FakeDeleteHotelParams());
    registerFallbackValue(FakeUploadImageParams());
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockCreateHotelUsecase = MockCreateHotelUsecase();
    mockGetAllHotelsUsecase = MockGetAllHotelsUsecase();
    mockGetHotelByIdUsecase = MockGetHotelByIdUsecase();
    mockUpdateHotelUsecase = MockUpdateHotelUsecase();
    mockDeleteHotelUsecase = MockDeleteHotelUsecase();
    mockUploadImageUsecase = MockUploadImageUsecase();

    tHotel = const HotelEntity(
      hotelId: 'hotel-123',
      hotelName: 'Grand Hotel',
      city: 'Kathmandu',
      price: 150.0,
      country: 'Nepal',
      address: '123 Main St',
      availableRooms: 10,
      rating: 4.5,
    );

    tHotels = [
      tHotel,
      const HotelEntity(
        hotelId: 'hotel-456',
        hotelName: 'Luxury Inn',
        city: 'Pokhara',
        price: 200.0,
        country: 'Nepal',
        address: '456 Lake Rd',
        availableRooms: 5,
        rating: 4.8,
      ),
    ];

    container = ProviderContainer(
      overrides: [
        createHotelUsecaseProvider.overrideWithValue(mockCreateHotelUsecase),
        getAllHotelsUsecaseProvider.overrideWithValue(mockGetAllHotelsUsecase),
        getHotelByIdUsecaseProvider.overrideWithValue(mockGetHotelByIdUsecase),
        updateHotelUsecaseProvider.overrideWithValue(mockUpdateHotelUsecase),
        deleteHotelUsecaseProvider.overrideWithValue(mockDeleteHotelUsecase),
        uploadImageProvider.overrideWithValue(mockUploadImageUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  HotelViewmodel readViewModel() =>
      container.read(hotelViewmodelProvider.notifier);

  HotelState readState() => container.read(hotelViewmodelProvider);

  group('HotelViewmodel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(HotelStatus.initial));
        expect(readState().hotels, isEmpty);
        expect(readState().selectedHotel, isNull);
        expect(readState().errorMessage, isNull);
        expect(readState().uploadImageName, isNull);
      });
    });

    group('createHotel', () {
      test('should emit loading then created status on success', () async {
        when(
          () => mockCreateHotelUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        await readViewModel().createHotel(
          hotelName: 'Grand Hotel',
          address: '123 Main St',
          country: 'Nepal',
          city: 'Kathmandu',
          availableRooms: 10,
          price: 150.0,
          rating: 4.5,
        );

        expect(readState().status, equals(HotelStatus.created));
      });

      test('should emit error status when createHotel fails', () async {
        const tFailure = ApiFailure(message: 'Failed to create hotel');
        when(
          () => mockCreateHotelUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().createHotel(
          hotelName: 'Grand Hotel',
          address: '123 Main St',
          country: 'Nepal',
          city: 'Kathmandu',
          availableRooms: 10,
          price: 150.0,
          rating: 4.5,
        );

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Failed to create hotel'));
      });
    });

    group('getAllHotels', () {
      test('should emit loading then loaded with hotels on success', () async {
        when(
          () => mockGetAllHotelsUsecase(),
        ).thenAnswer((_) async => Right<Failure, List<HotelEntity>>(tHotels));

        await readViewModel().getAllHotels();

        expect(readState().status, equals(HotelStatus.loaded));
        expect(readState().hotels, equals(tHotels));
      });

      test('should emit error status when getAllHotels fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load hotels');
        when(
          () => mockGetAllHotelsUsecase(),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getAllHotels();

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Failed to load hotels'));
      });
    });

    group('getHotelById', () {
      test(
        'should emit loading then loaded with selectedHotel on success',
        () async {
          when(
            () => mockGetHotelByIdUsecase(any()),
          ).thenAnswer((_) async => Right(tHotel));

          await readViewModel().getHotelById('hotel-123');

          expect(readState().status, equals(HotelStatus.loaded));
          expect(readState().selectedHotel, equals(tHotel));
        },
      );

      test('should emit error status when getHotelById fails', () async {
        const tFailure = ApiFailure(message: 'Hotel not found');
        when(
          () => mockGetHotelByIdUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getHotelById('hotel-123');

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Hotel not found'));
      });
    });

    group('updateHotel', () {
      test('should emit loading then updated status on success', () async {
        when(
          () => mockUpdateHotelUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        // getAllHotels is called after update
        when(
          () => mockGetAllHotelsUsecase(),
        ).thenAnswer((_) async => Right<Failure, List<HotelEntity>>(tHotels));

        await readViewModel().updateHotel(tHotel);
        // wait for the fire-and-forget getAllHotels to complete
        await Future.microtask(() {});

        expect(readState().status, equals(HotelStatus.loaded));
      });

      test('should emit error status when updateHotel fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update hotel');
        when(
          () => mockUpdateHotelUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updateHotel(tHotel);

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Failed to update hotel'));
      });
    });

    group('deleteHotel', () {
      test('should emit loading then deleted status on success', () async {
        when(
          () => mockDeleteHotelUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        // getAllHotels is called after delete
        when(
          () => mockGetAllHotelsUsecase(),
        ).thenAnswer((_) async => Right<Failure, List<HotelEntity>>(tHotels));

        await readViewModel().deleteHotel('hotel-123');
        // wait for the fire-and-forget getAllHotels to complete
        await Future.microtask(() {});

        expect(readState().status, equals(HotelStatus.loaded));
      });

      test('should emit error status when deleteHotel fails', () async {
        const tFailure = ApiFailure(message: 'Failed to delete hotel');
        when(
          () => mockDeleteHotelUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().deleteHotel('hotel-123');

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Failed to delete hotel'));
      });
    });

    group('uploadImage', () {
      test(
        'should emit loading then loaded with uploadImageName on success',
        () async {
          when(
            () => mockUploadImageUsecase(any()),
          ).thenAnswer((_) async => const Right('image-abc123.jpg'));

          await readViewModel().uploadImage(FakeFile());

          expect(readState().status, equals(HotelStatus.loaded));
          expect(readState().uploadImageName, equals('image-abc123.jpg'));
        },
      );

      test('should emit error status when uploadImage fails', () async {
        const tFailure = ApiFailure(message: 'Failed to upload image');
        when(
          () => mockUploadImageUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().uploadImage(FakeFile());

        expect(readState().status, equals(HotelStatus.error));
        expect(readState().errorMessage, equals('Failed to upload image'));
      });
    });
  });
}
