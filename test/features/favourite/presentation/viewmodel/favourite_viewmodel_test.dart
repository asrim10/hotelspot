import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/favourites/presentation/view_model/favourite_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/domain/usecases/add_to_favourite_usecase.dart';
import 'package:hotelspot/features/favourites/domain/usecases/get_my_favourite_usecase.dart';
import 'package:hotelspot/features/favourites/domain/usecases/remove_favourite_usecase.dart';
import 'package:hotelspot/features/favourites/presentation/state/favourite_state.dart';

// Mocks
class MockAddToFavouritesUsecase extends Mock
    implements AddToFavouritesUsecase {}

class MockGetMyFavouritesUsecase extends Mock
    implements GetMyFavouritesUsecase {}

class MockRemoveFavouriteUsecase extends Mock
    implements RemoveFavouriteUsecase {}

// Fakes
class FakeAddToFavouritesParams extends Fake implements AddToFavouritesParams {}

class FakeGetMyFavouritesParams extends Fake implements GetMyFavouritesParams {}

class FakeRemoveFavouriteParams extends Fake implements RemoveFavouriteParams {}

void main() {
  late MockAddToFavouritesUsecase mockAddToFavouritesUsecase;
  late MockGetMyFavouritesUsecase mockGetMyFavouritesUsecase;
  late MockRemoveFavouriteUsecase mockRemoveFavouriteUsecase;
  late ProviderContainer container;
  late FavouriteEntity tFavourite;
  late List<FavouriteEntity> tFavourites;

  setUpAll(() {
    registerFallbackValue(FakeAddToFavouritesParams());
    registerFallbackValue(FakeGetMyFavouritesParams());
    registerFallbackValue(FakeRemoveFavouriteParams());
  });

  setUp(() {
    mockAddToFavouritesUsecase = MockAddToFavouritesUsecase();
    mockGetMyFavouritesUsecase = MockGetMyFavouritesUsecase();
    mockRemoveFavouriteUsecase = MockRemoveFavouriteUsecase();

    tFavourite = FavouriteEntity(
      favouriteId: 'fav-001',
      userId: 'user-456',
      hotelId: 'hotel-123',
    );

    tFavourites = [
      tFavourite,
      FavouriteEntity(
        favouriteId: 'fav-002',
        userId: 'user-456',
        hotelId: 'hotel-789',
      ),
    ];

    container = ProviderContainer(
      overrides: [
        addToFavouritesUsecaseProvider.overrideWithValue(
          mockAddToFavouritesUsecase,
        ),
        getMyFavouritesUsecaseProvider.overrideWithValue(
          mockGetMyFavouritesUsecase,
        ),
        removeFavouriteUsecaseProvider.overrideWithValue(
          mockRemoveFavouriteUsecase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  FavouriteViewModel readViewModel() =>
      container.read(favouriteViewModelProvider.notifier);

  FavouriteState readState() => container.read(favouriteViewModelProvider);

  group('FavouriteViewModel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(FavouriteStatus.initial));
        expect(readState().favourites, isEmpty);
        expect(readState().currentFavourite, isNull);
        expect(readState().errorMessage, isNull);
      });
    });

    group('addToFavourites', () {
      test('should emit adding then added status on success', () async {
        when(
          () => mockAddToFavouritesUsecase(any()),
        ).thenAnswer((_) async => Right(tFavourite));

        await readViewModel().addToFavourites(tFavourite);

        expect(readState().status, equals(FavouriteStatus.added));
        expect(readState().favourites, contains(tFavourite));
        expect(readState().currentFavourite, equals(tFavourite));
      });

      test('should emit error status when addToFavourites fails', () async {
        const tFailure = ApiFailure(message: 'Failed to add favourite');
        when(
          () => mockAddToFavouritesUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().addToFavourites(tFavourite);

        expect(readState().status, equals(FavouriteStatus.error));
        expect(readState().errorMessage, equals('Failed to add favourite'));
      });
    });

    group('getMyFavourites', () {
      test('should emit loading then loaded status on success', () async {
        when(
          () => mockGetMyFavouritesUsecase(any()),
        ).thenAnswer((_) async => Right(tFavourites));

        await readViewModel().getMyFavourites('user-456');

        expect(readState().status, equals(FavouriteStatus.loaded));
        expect(readState().favourites, equals(tFavourites));
      });

      test('should emit error status when getMyFavourites fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load favourites');
        when(
          () => mockGetMyFavouritesUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getMyFavourites('user-456');

        expect(readState().status, equals(FavouriteStatus.error));
        expect(readState().errorMessage, equals('Failed to load favourites'));
      });
    });

    group('removeFromFavourites', () {
      test(
        'should emit removing then removed status and update list on success',
        () async {
          // Pre-populate state with favourites
          when(
            () => mockGetMyFavouritesUsecase(any()),
          ).thenAnswer((_) async => Right(tFavourites));
          await readViewModel().getMyFavourites('user-456');

          when(
            () => mockRemoveFavouriteUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          await readViewModel().removeFromFavourites('fav-001');

          expect(readState().status, equals(FavouriteStatus.removed));
          expect(
            readState().favourites.any((fav) => fav.favouriteId == 'fav-001'),
            isFalse,
          );
        },
      );

      test(
        'should emit error status when removeFromFavourites fails',
        () async {
          const tFailure = ApiFailure(message: 'Failed to remove favourite');
          when(
            () => mockRemoveFavouriteUsecase(any()),
          ).thenAnswer((_) async => const Left(tFailure));

          await readViewModel().removeFromFavourites('fav-001');

          expect(readState().status, equals(FavouriteStatus.error));
          expect(
            readState().errorMessage,
            equals('Failed to remove favourite'),
          );
        },
      );

      test(
        'should emit error status when removeFromFavourites returns false',
        () async {
          when(
            () => mockRemoveFavouriteUsecase(any()),
          ).thenAnswer((_) async => const Right(false));

          await readViewModel().removeFromFavourites('fav-001');

          expect(readState().status, equals(FavouriteStatus.error));
          expect(
            readState().errorMessage,
            equals('Failed to remove favourite'),
          );
        },
      );
    });

    group('resetState', () {
      test('should reset state back to initial', () async {
        when(
          () => mockGetMyFavouritesUsecase(any()),
        ).thenAnswer((_) async => Right(tFavourites));
        await readViewModel().getMyFavourites('user-456');

        readViewModel().resetState();

        expect(readState().status, equals(FavouriteStatus.initial));
        expect(readState().favourites, isEmpty);
        expect(readState().currentFavourite, isNull);
        expect(readState().errorMessage, isNull);
      });
    });

    group('clearError', () {
      test('should reset status to initial after error', () async {
        const tFailure = ApiFailure(message: 'Some error');
        when(
          () => mockGetMyFavouritesUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        await readViewModel().getMyFavourites('user-456');

        readViewModel().clearError();

        expect(readState().status, equals(FavouriteStatus.initial));
      });
    });
  });
}
