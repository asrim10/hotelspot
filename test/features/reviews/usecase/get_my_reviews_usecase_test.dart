import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_my_reviews_usecase.dart';

// Mock
class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late GetMyReviewsUsecase getMyReviewsUsecase;
  late MockReviewRepository mockReviewRepository;
  late List<ReviewEntity> tReviews;

  setUp(() {
    mockReviewRepository = MockReviewRepository();
    getMyReviewsUsecase = GetMyReviewsUsecase(
      reviewRepository: mockReviewRepository,
    );
    tReviews = [
      ReviewEntity(
        reviewId: 'review-001',
        userId: 'user-456',
        hotelId: 'hotel-123',
        fullName: 'John Doe',
        email: 'johndoe@email.com',
        rating: 4.5,
        comment: 'Great hotel!',
      ),
      ReviewEntity(
        reviewId: 'review-002',
        userId: 'user-456',
        hotelId: 'hotel-789',
        fullName: 'John Doe',
        email: 'johndoe@email.com',
        rating: 3.0,
        comment: 'Average experience.',
      ),
    ];
  });

  group('GetMyReviewsUsecase', () {
    // Returns list of reviews on success
    test('should return list of ReviewEntity when successful', () async {
      when(
        () => mockReviewRepository.getMyReviews(),
      ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>(tReviews));

      final result = await getMyReviewsUsecase();

      expect(result, Right<Failure, List<ReviewEntity>>(tReviews));
      verify(() => mockReviewRepository.getMyReviews()).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Returns empty list when user has no reviews
    test('should return empty list when user has no reviews', () async {
      when(
        () => mockReviewRepository.getMyReviews(),
      ).thenAnswer((_) async => Right<Failure, List<ReviewEntity>>([]));

      final result = await getMyReviewsUsecase();

      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (reviews) => expect(reviews, isEmpty),
      );
      verify(() => mockReviewRepository.getMyReviews()).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to get reviews');
      when(
        () => mockReviewRepository.getMyReviews(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await getMyReviewsUsecase();

      expect(result, const Left<Failure, List<ReviewEntity>>(tFailure));
      verify(() => mockReviewRepository.getMyReviews()).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });
  });
}
