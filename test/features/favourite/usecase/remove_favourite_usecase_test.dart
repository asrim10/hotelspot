import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/favourites/domain/usecases/remove_favourite_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/favourites/domain/repositories/favourite_repository.dart';

// Mock
class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

void main() {
  late RemoveFavouriteUsecase removeFavouriteUsecase;
  late MockFavouriteRepository mockFavouriteRepository;
  late RemoveFavouriteParams tParams;

  setUp(() {
    mockFavouriteRepository = MockFavouriteRepository();
    removeFavouriteUsecase = RemoveFavouriteUsecase(
      favouriteRepository: mockFavouriteRepository,
    );
    tParams = const RemoveFavouriteParams(favouriteId: 'fav-001');
  });

  group('RemoveFavouriteUsecase', () {
    // Returns true on successful removal
    test('should return true when favourite is removed successfully', () async {
      when(
        () => mockFavouriteRepository.removeFromFavourites(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await removeFavouriteUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockFavouriteRepository.removeFromFavourites('fav-001'),
      ).called(1);
      verifyNoMoreInteractions(mockFavouriteRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to remove favourite');
      when(
        () => mockFavouriteRepository.removeFromFavourites(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await removeFavouriteUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(
        () => mockFavouriteRepository.removeFromFavourites('fav-001'),
      ).called(1);
      verifyNoMoreInteractions(mockFavouriteRepository);
    });

    // Passes correct favouriteId to repository
    test(
      'should call repository with correct favouriteId from params',
      () async {
        when(
          () => mockFavouriteRepository.removeFromFavourites(any()),
        ).thenAnswer((_) async => const Right(true));

        await removeFavouriteUsecase(tParams);

        final captured = verify(
          () => mockFavouriteRepository.removeFromFavourites(captureAny()),
        ).captured;

        expect(captured.first, equals('fav-001'));
      },
    );
  });
}
