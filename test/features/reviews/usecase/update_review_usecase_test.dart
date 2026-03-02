import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/usecases/update_review_usecase.dart';

// Mock
class MockReviewRepository extends Mock implements IReviewRepository {}

class FakeReviewEntity extends Fake implements ReviewEntity {}

void main() {
  late UpdateReviewUsecase updateReviewUsecase;
  late MockReviewRepository mockReviewRepository;
  late UpdateReviewParams tParams;

  setUpAll(() {
    registerFallbackValue(FakeReviewEntity());
  });

  setUp(() {
    mockReviewRepository = MockReviewRepository();
    updateReviewUsecase = UpdateReviewUsecase(
      reviewRepository: mockReviewRepository,
    );
    tParams = const UpdateReviewParams(
      reviewId: 'review-001',
      userId: 'user-456',
      hotelId: 'hotel-123',
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      rating: 4.5,
      comment: 'Updated review comment',
    );
  });

  group('UpdateReviewUsecase', () {
    // Returns true on successful update
    test('should return true when review is updated successfully', () async {
      when(
        () => mockReviewRepository.updateReview(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await updateReviewUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockReviewRepository.updateReview(any())).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to update review');
      when(
        () => mockReviewRepository.updateReview(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await updateReviewUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockReviewRepository.updateReview(any())).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Passes correct ReviewEntity built from params to repository
    test(
      'should call repository with correct ReviewEntity from params',
      () async {
        when(
          () => mockReviewRepository.updateReview(any()),
        ).thenAnswer((_) async => const Right(true));

        await updateReviewUsecase(tParams);

        final captured = verify(
          () => mockReviewRepository.updateReview(captureAny()),
        ).captured;

        final capturedEntity = captured.first as ReviewEntity;
        expect(capturedEntity.reviewId, equals('review-001'));
        expect(capturedEntity.userId, equals('user-456'));
        expect(capturedEntity.hotelId, equals('hotel-123'));
        expect(capturedEntity.fullName, equals('John Doe'));
        expect(capturedEntity.email, equals('johndoe@email.com'));
        expect(capturedEntity.rating, equals(4.5));
        expect(capturedEntity.comment, equals('Updated review comment'));
      },
    );
  });
}
