import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/usecases/delete_review_usecase.dart';

// Mock
class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late DeleteReviewUsecase deleteReviewUsecase;
  late MockReviewRepository mockReviewRepository;
  late DeleteReviewParams tParams;

  setUp(() {
    mockReviewRepository = MockReviewRepository();
    deleteReviewUsecase = DeleteReviewUsecase(
      reviewRepository: mockReviewRepository,
    );
    tParams = const DeleteReviewParams(reviewId: 'review-001');
  });

  group('DeleteReviewUsecase', () {
    // Returns true on successful deletion
    test('should return true when review is deleted successfully', () async {
      when(
        () => mockReviewRepository.deleteReview(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await deleteReviewUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockReviewRepository.deleteReview('review-001')).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to delete review');
      when(
        () => mockReviewRepository.deleteReview(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await deleteReviewUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockReviewRepository.deleteReview('review-001')).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Passes correct reviewId to repository
    test('should call repository with correct reviewId from params', () async {
      when(
        () => mockReviewRepository.deleteReview(any()),
      ).thenAnswer((_) async => const Right(true));

      await deleteReviewUsecase(tParams);

      final captured = verify(
        () => mockReviewRepository.deleteReview(captureAny()),
      ).captured;

      expect(captured.first, equals('review-001'));
    });
  });
}
