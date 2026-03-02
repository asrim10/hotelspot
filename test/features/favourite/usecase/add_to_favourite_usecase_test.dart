import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/favourites/domain/usecases/add_to_favourite_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

// Mock
class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

// Fake (needed for registerFallbackValue since addToFavourites() takes FavouriteEntity)
class FakeFavouriteEntity extends Fake implements FavouriteEntity {}

void main() {
  late AddToFavouritesUsecase addToFavouritesUsecase;
  late MockFavouriteRepository mockFavouriteRepository;
  late AddToFavouritesParams tParams;
  late FavouriteEntity tFavouriteEntity;

  setUpAll(() {
    registerFallbackValue(FakeFavouriteEntity());
  });

  setUp(() {
    mockFavouriteRepository = MockFavouriteRepository();
    addToFavouritesUsecase = AddToFavouritesUsecase(
      favouriteRepository: mockFavouriteRepository,
    );
    tParams = const AddToFavouritesParams(
      userId: 'user-456',
      hotelId: 'hotel-123',
    );
    tFavouriteEntity = FavouriteEntity(
      favouriteId: 'fav-001',
      userId: 'user-456',
      hotelId: 'hotel-123',
    );
  });

  group('AddToFavouritesUsecase', () {
    // Returns FavouriteEntity on success
    test(
      'should return FavouriteEntity when added to favourites successfully',
      () async {
        when(
          () => mockFavouriteRepository.addToFavourites(any()),
        ).thenAnswer((_) async => Right(tFavouriteEntity));

        final result = await addToFavouritesUsecase(tParams);

        expect(result, Right<Failure, FavouriteEntity>(tFavouriteEntity));
        verify(() => mockFavouriteRepository.addToFavourites(any())).called(1);
        verifyNoMoreInteractions(mockFavouriteRepository);
      },
    );

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to add to favourites');
      when(
        () => mockFavouriteRepository.addToFavourites(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await addToFavouritesUsecase(tParams);

      expect(result, const Left<Failure, FavouriteEntity>(tFailure));
      verify(() => mockFavouriteRepository.addToFavourites(any())).called(1);
      verifyNoMoreInteractions(mockFavouriteRepository);
    });

    // Passes correct FavouriteEntity built from params to repository
    test(
      'should call repository with correct FavouriteEntity from params',
      () async {
        when(
          () => mockFavouriteRepository.addToFavourites(any()),
        ).thenAnswer((_) async => Right(tFavouriteEntity));

        await addToFavouritesUsecase(tParams);

        final captured = verify(
          () => mockFavouriteRepository.addToFavourites(captureAny()),
        ).captured;

        final capturedEntity = captured.first as FavouriteEntity;
        expect(capturedEntity.userId, equals('user-456'));
        expect(capturedEntity.hotelId, equals('hotel-123'));
        expect(capturedEntity.favouriteId, isNull);
      },
    );

    // FavouriteEntity is built with null favouriteId
    test('should build FavouriteEntity with null favouriteId', () async {
      when(
        () => mockFavouriteRepository.addToFavourites(any()),
      ).thenAnswer((_) async => Right(tFavouriteEntity));

      await addToFavouritesUsecase(tParams);

      final captured = verify(
        () => mockFavouriteRepository.addToFavourites(captureAny()),
      ).captured;

      final capturedEntity = captured.first as FavouriteEntity;
      expect(capturedEntity.favouriteId, isNull);
    });
  });
}
