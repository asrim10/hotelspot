import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_review_by_id_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_my_reviews_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_reviews_by_hotel_id_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/update_review_usecase.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';

// Mocks
class MockGetReviewsByHotelIdUsecase extends Mock
    implements GetReviewsByHotelIdUsecase {}

class MockGetMyReviewsUsecase extends Mock implements GetMyReviewsUsecase {}

class MockGetReviewByIdUsecase extends Mock implements GetReviewByIdUsecase {}

class MockCreateReviewUsecase extends Mock implements CreateReviewUsecase {}

class MockUpdateReviewUsecase extends Mock implements UpdateReviewUsecase {}

class MockDeleteReviewUsecase extends Mock implements DeleteReviewUsecase {}

// Fakes
class FakeGetReviewsByHotelIdParams extends Fake
    implements GetReviewsByHotelIdParams {}

class FakeGetReviewByIdParams extends Fake implements GetReviewByIdParams {}

class FakeCreateReviewParams extends Fake implements CreateReviewParams {}

class FakeUpdateReviewParams extends Fake implements UpdateReviewParams {}

class FakeDeleteReviewParams extends Fake implements DeleteReviewParams {}

void main() {
  late MockGetReviewsByHotelIdUsecase mockGetReviewsByHotelIdUsecase;
  late MockGetMyReviewsUsecase mockGetMyReviewsUsecase;
  late MockGetReviewByIdUsecase mockGetReviewByIdUsecase;
  late MockCreateReviewUsecase mockCreateReviewUsecase;
  late MockUpdateReviewUsecase mockUpdateReviewUsecase;
  late MockDeleteReviewUsecase mockDeleteReviewUsecase;
  late ProviderContainer container;
  late ReviewEntity tReview;
  late List<ReviewEntity> tReviews;

  setUpAll(() {
    registerFallbackValue(FakeGetReviewsByHotelIdParams());
    registerFallbackValue(FakeGetReviewByIdParams());
    registerFallbackValue(FakeCreateReviewParams());
    registerFallbackValue(FakeUpdateReviewParams());
    registerFallbackValue(FakeDeleteReviewParams());
  });

  setUp(() {
    mockGetReviewsByHotelIdUsecase = MockGetReviewsByHotelIdUsecase();
    mockGetMyReviewsUsecase = MockGetMyReviewsUsecase();
    mockGetReviewByIdUsecase = MockGetReviewByIdUsecase();
    mockCreateReviewUsecase = MockCreateReviewUsecase();
    mockUpdateReviewUsecase = MockUpdateReviewUsecase();
    mockDeleteReviewUsecase = MockDeleteReviewUsecase();

    tReview = ReviewEntity(
      reviewId: 'review-001',
      userId: 'user-456',
      hotelId: 'hotel-123',
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      rating: 4.5,
      comment: 'Great hotel!',
    );

    tReviews = [
      tReview,
      ReviewEntity(
        reviewId: 'review-002',
        userId: 'user-789',
        hotelId: 'hotel-123',
        fullName: 'Jane Doe',
        email: 'janedoe@email.com',
        rating: 3.0,
        comment: 'Average experience.',
      ),
    ];

    container = ProviderContainer(
      overrides: [
        getReviewsByHotelIdUsecaseProvider.overrideWithValue(
          mockGetReviewsByHotelIdUsecase,
        ),
        getMyReviewsUsecaseProvider.overrideWithValue(mockGetMyReviewsUsecase),
        getReviewByIdUsecaseProvider.overrideWithValue(
          mockGetReviewByIdUsecase,
        ),
        createReviewUsecaseProvider.overrideWithValue(mockCreateReviewUsecase),
        updateReviewUsecaseProvider.overrideWithValue(mockUpdateReviewUsecase),
        deleteReviewUsecaseProvider.overrideWithValue(mockDeleteReviewUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  ReviewViewmodel readViewModel() =>
      container.read(reviewViewmodelProvider.notifier);

  ReviewState readState() => container.read(reviewViewmodelProvider);

  group('ReviewViewmodel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(ReviewStatus.initial));
        expect(readState().reviews, isEmpty);
        expect(readState().myReviews, isEmpty);
        expect(readState().selectedReview, isNull);
        expect(readState().errorMessage, isNull);
      });
    });

    group('getReviewsByHotelId', () {
      test('should emit loading then loaded with reviews on success', () async {
        when(
          () => mockGetReviewsByHotelIdUsecase(any()),
        ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>(tReviews));

        await readViewModel().getReviewsByHotelId('hotel-123');

        expect(readState().status, equals(ReviewStatus.loaded));
        expect(readState().reviews, equals(tReviews));
      });

      test('should emit error status when getReviewsByHotelId fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load reviews');
        when(
          () => mockGetReviewsByHotelIdUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getReviewsByHotelId('hotel-123');

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Failed to load reviews'));
      });
    });

    group('getMyReviews', () {
      test(
        'should emit loading then loaded with myReviews on success',
        () async {
          when(() => mockGetMyReviewsUsecase()).thenAnswer(
            (_) async => Right<Failure, List<ReviewEntity>>(tReviews),
          );

          await readViewModel().getMyReviews();

          expect(readState().status, equals(ReviewStatus.loaded));
          expect(readState().myReviews, equals(tReviews));
        },
      );

      test('should emit error status when getMyReviews fails', () async {
        const tFailure = ApiFailure(message: 'Failed to load my reviews');
        when(
          () => mockGetMyReviewsUsecase(),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getMyReviews();

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Failed to load my reviews'));
      });
    });

    group('getReviewById', () {
      test(
        'should emit loading then loaded with selectedReview on success',
        () async {
          when(
            () => mockGetReviewByIdUsecase(any()),
          ).thenAnswer((_) async => Right(tReview));

          await readViewModel().getReviewById('review-001');

          expect(readState().status, equals(ReviewStatus.loaded));
          expect(readState().selectedReview, equals(tReview));
        },
      );

      test('should emit error status when getReviewById fails', () async {
        const tFailure = ApiFailure(message: 'Review not found');
        when(
          () => mockGetReviewByIdUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().getReviewById('review-001');

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Review not found'));
      });
    });

    group('createReview', () {
      test('should emit loading then created status on success', () async {
        when(
          () => mockCreateReviewUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        // getReviewsByHotelId is called after create
        when(
          () => mockGetReviewsByHotelIdUsecase(any()),
        ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>(tReviews));

        await readViewModel().createReview(
          hotelId: 'hotel-123',
          rating: 4.5,
          comment: 'Great hotel!',
        );
        // wait for the fire-and-forget getReviewsByHotelId to complete
        await Future.microtask(() {});

        expect(readState().status, equals(ReviewStatus.loaded));
      });

      test('should emit error status when createReview fails', () async {
        const tFailure = ApiFailure(message: 'Failed to create review');
        when(
          () => mockCreateReviewUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().createReview(
          hotelId: 'hotel-123',
          rating: 4.5,
          comment: 'Great hotel!',
        );

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Failed to create review'));
      });
    });

    group('updateReview', () {
      test('should emit loading then updated status on success', () async {
        when(
          () => mockUpdateReviewUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        // getReviewsByHotelId is called after update
        when(
          () => mockGetReviewsByHotelIdUsecase(any()),
        ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>(tReviews));

        await readViewModel().updateReview(
          reviewId: 'review-001',
          userId: 'user-456',
          hotelId: 'hotel-123',
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          rating: 5.0,
          comment: 'Updated comment',
        );
        // wait for the fire-and-forget getReviewsByHotelId to complete
        await Future.microtask(() {});

        expect(readState().status, equals(ReviewStatus.loaded));
      });

      test('should emit error status when updateReview fails', () async {
        const tFailure = ApiFailure(message: 'Failed to update review');
        when(
          () => mockUpdateReviewUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().updateReview(
          reviewId: 'review-001',
          userId: 'user-456',
          hotelId: 'hotel-123',
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          rating: 5.0,
          comment: 'Updated comment',
        );

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Failed to update review'));
      });
    });

    group('deleteReview', () {
      test('should emit loading then deleted status on success', () async {
        when(
          () => mockDeleteReviewUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        // getReviewsByHotelId is called after delete
        when(
          () => mockGetReviewsByHotelIdUsecase(any()),
        ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>(tReviews));

        await readViewModel().deleteReview(
          reviewId: 'review-001',
          hotelId: 'hotel-123',
        );
        // wait for the fire-and-forget getReviewsByHotelId to complete
        await Future.microtask(() {});

        expect(readState().status, equals(ReviewStatus.loaded));
      });

      test('should emit error status when deleteReview fails', () async {
        const tFailure = ApiFailure(message: 'Failed to delete review');
        when(
          () => mockDeleteReviewUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().deleteReview(
          reviewId: 'review-001',
          hotelId: 'hotel-123',
        );

        expect(readState().status, equals(ReviewStatus.error));
        expect(readState().errorMessage, equals('Failed to delete review'));
      });
    });
  });
}
